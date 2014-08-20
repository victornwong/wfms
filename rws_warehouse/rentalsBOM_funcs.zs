
import org.victor.*;

// other supporting funcs used in rentalsBOM_v1
/*
SimpleDateFormat dtf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
SimpleDateFormat dtf2 = new SimpleDateFormat("yyyy-MM-dd");
*/
// irecs: stockrentalitems_det recs digged
boolean checkDupParts(Object irecs)
{
	HashMap hm = new HashMap();
	retval = false;
	String[] partsid = { "ram","ram2","ram3","ram4","hdd","hdd2","hdd3","hdd4",
	"battery","gfxcard" }; // TODO HARDCODED
	// count parts
	/*
	bomtype,cpu,ram,hdd,battery,gfxcard,poweradaptor,vgacable,mouse,keyboard," + 
	"monitor,asset_tag
	*/
	for(di : irecs)
	{
		bomty = kiboo.checkNullString(di.get("bomtype")).trim();

		for(i=0;i<partsid.length;i++) // chk dup parts in BOM builds
		{
			ikl = kiboo.checkNullString( di.get(partsid[i]) ).trim();
			if(!ikl.equals("")) hm.put(ikl, ( (hm.containsKey(ikl)) ? 2 : 1) );
		}

		ipwr = kiboo.checkNullString(di.get("poweradaptor")).trim();
		imoni = kiboo.checkNullString(di.get("monitor")).trim();
		iatg = kiboo.checkNullString(di.get("asset_tag")).trim();

		// only count power-adaptor if bomtype=notebook
		if(bomty.equals("NOTEBOOK"))
			if(!ipwr.equals("")) hm.put(ipwr, ((hm.containsKey(ipwr)) ? 2 : 1) );

		if(!imoni.equals("")) hm.put(imoni, ((hm.containsKey(imoni)) ? 2 : 1) );
		if(!iatg.equals("")) hm.put(iatg, ((hm.containsKey(iatg)) ? 2 : 1) );
	}
	ptsck = hm.values().toArray(); // chk for dups
//msg = "";
	for(i=0;i<ptsck.length;i++)
	{
		if(ptsck[i] != 1) { retval = true; break; }
//msg += ptsck[i].toString() + " :: ";
	}
//alert(irecs + "---" + msg);
	return retval;
}

// check if parts alloced or non-exist TODO checkReplacementParts() in replacementsMan_v1.zul almost the same..
// retval: 1=non-exist, 2=parts exist and already alloced for other BOM, 3=parts in RMA, 4=parts in a pick-list
int checkPartStock_alloced(String istockcode, String istkcat)
{
	retval = 0;
	sqlstm = "select bom_id,rma_id,pick_id from stockmasterdetails where stock_code='" + istockcode.trim() + "' and stock_cat='" + istkcat + "'";
	ichk = sqlhand.gpSqlFirstRow(sqlstm);
	if(ichk != null)
	{
		if(ichk.get("bom_id") != null) retval = 2;
		if(ichk.get("rma_id") != null) retval = 3;
		if(ichk.get("pick_id") != null) retval = 4;
	}
	else
		retval = 1;

	return retval;
}

// retv: 1=asset-tag non-exist, 2=isactive non-rentable, 3=already in another bom, 4=wrong build-type, 5=in RMA
int checkAssetTagUsed(String iasstg, String ibuildtype)
{
	retv = 0;
	sqlstm = "select stock_cat, isactive, bom_id, rma_id from stockmasterdetails where stock_code='" + iasstg + "'";
	krc = sqlhand.gpSqlFirstRow(sqlstm);
	if(krc == null)
	{
		retv = 1;
	}
	else
	{
		kisa = (krc.get("isactive") == null) ? false : krc.get("isactive");
		if(!kisa) retv = 2;
		kbom = (krc.get("bom_id") == null) ? "" : krc.get("bom_id");
		if(!kbom.equals("")) retv = 3;

		stkcat = kiboo.checkNullString(krc.get("stock_cat"));
		if(!stkcat.equals(ibuildtype)) retv = 4;
		if(krc.get("rma_id") != null) retv = 5;
	}
	return retv;
}

void showPartsAuditLog(Object iwhat)
{
	itype = iwhat.getId();
	whatchk = null;

	String[] bt = { "pickcpu_butt", "pickram_butt", "pickram2_butt", "pickram3_butt", "pickram4_butt",
	"pickhdd_butt", "pickhdd2_butt", "pickhdd3_butt", "pickhdd4_butt",
	"pickpoweradapt_butt", "pickbatt_butt", "pickgfx_butt", "pickmonitor_butt" };

	Object[] ob = { m_asset_tag, m_ram, m_ram2, m_ram3, m_ram4, m_hdd, m_hdd2, m_hdd3, m_hdd4,
	m_poweradaptor, m_battery, m_gfxcard, m_monitor };

	for(i=0; i<bt.length; i++)
	{
		if(itype.equals(bt[i])) { whatchk = ob[i]; break; }
	}

	if(whatchk != null)
	{
		tstkc = kiboo.replaceSingleQuotes(whatchk.getValue().trim());
		if(tstkc.equals("")) return;
		showSystemAudit(auditlogs_holder,tstkc,"");
		auditlogs_pop.open(iwhat);
	}
}

void toggleBuildsButts(boolean iwhat)
{
	Object[] dk = { assigncust_b, updatebom_butt, newdesktop_butt, newnotebook_butt,
	newmonitor_butt, delbuilds_butt, updbuild_b, getjobid_b };

	tongComponents(dk,iwhat);
}

void tongComponents(Object[] icmps, boolean iwhat)
{
	for(i=0;i<icmps.length;i++)
	{
		icmps[i].setDisabled(iwhat);
	}
}

// itype: 1=desktop, 2=notebook, 3=monitor
void togglePartsButtons(int itype)
{
	Object[] dis3 = { pickcpu_butt, pickram_butt, pickram2_butt, pickram3_butt, pickram4_butt,
		pickhdd_butt, pickhdd2_butt, pickhdd3_butt, pickhdd4_butt, pickbatt_butt, pickgfx_butt,
		pickvgac_butt, pickmse_butt, pickkbd_butt, pickpoweradapt_butt, pickmonitor_butt,
		m_cpu, m_ram, m_ram2, m_ram3, m_ram4, m_hdd, m_hdd2, m_hdd3, m_hdd4,
		m_battery, m_poweradaptor, m_gfxcard, m_vgacable, m_mouse, m_keyboard, m_monitor };

	tongComponents(dis3,false);

	if(itype == 1)
	{
		Object[] d1 = { pickbatt_butt, m_battery, pickpoweradapt_butt, m_poweradaptor };

		tongComponents(d1,true);
	}

	if(itype == 2) // notebook
	{
		Object[] d4 = {
		pickgfx_butt, pickvgac_butt, pickmse_butt, pickkbd_butt, pickmonitor_butt,
		m_gfxcard, m_vgacable, m_mouse, m_keyboard, m_monitor
		};

		tongComponents(d4,true);
	}

	if(itype == 3) // monitor
	{
		tongComponents(dis3,true);
	}
}

// clear build-items textboxes
void clearBuilds_items()
{
	Object[] en1 = { m_asset_tag, m_description,
		m_cpu, m_ram, m_ram2, m_ram3, m_ram4, m_hdd, m_hdd2, m_hdd3, m_hdd4,
		m_battery, m_poweradaptor, m_gfxcard, m_vgacable, m_mouse, m_keyboard, m_monitor,
		m_misc, coa1, coa2, coa3, coa4,
		n_cpu, n_ram, n_ram2, n_ram3, n_ram4,
		n_hdd, n_hdd2, n_hdd3, n_hdd4,
		n_battery, n_gfxcard, n_vgacable, n_mouse,
		n_keyboard, n_poweradaptor, n_monitor };

	clearUI_Field(en1);
	lbhand.matchListboxItems( osversion, "NONE" );
	lbhand.matchListboxItems( offapps, "NONE" );
}

void showBOMMetadata(String ibom)
{
	bmr = getBOM_rec(ibom);
	if(bmr == null) { guihand.showMessageBox("ERR: Cannot access BOM table"); return; }

	bomheader.setValue(BOM_PREFIX + ibom);
	bomuserheader.setValue("User: " + kiboo.checkNullString(bmr.get("createdby")) );
	customername.setValue( kiboo.checkNullString(bmr.get("customer_name")) );
	lbhand.matchListboxItems(bomcategory, kiboo.checkNullString(bmr.get("bomcategory")) );

	jid = (bmr.get("job_id") == null) ? "" : bmr.get("job_id").toString();
	job_id.setValue(jid);

	showJobNotes(JN_linkcode(),jobnotes_holder,"jobnotes_lb"); // customize accordingly here..
	jobnotes_div.setVisible(true);

	workarea.setVisible(true);

	if(workarea.getFellowIfAny("shwmini_ji_row") != null)
		shwmini_ji_row.setVisible(false);

}

Object[] bomslb_headers = 
{
	new listboxHeaderWidthObj("BOM#",true,"70px"),
	new listboxHeaderWidthObj("Dated",true,"60px"),
	new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("User",true,"60px"),
	new listboxHeaderWidthObj("Stat",true,"30px"),
	new listboxHeaderWidthObj("Catg",true,"60px"),
	new listboxHeaderWidthObj("Job",true,"60px"),

};

class bomslbClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		cel1 = lbhand.getListcellItemLabel(isel,0);

		global_selected_bom = cel1.substring(3,cel1.length());
		global_selected_customer = lbhand.getListcellItemLabel(isel,2);

		global_bom_user = lbhand.getListcellItemLabel(isel,3);
		global_sel_bom_status = lbhand.getListcellItemLabel(isel,4);

		glob_sel_bomcategory = lbhand.getListcellItemLabel(isel,5);
		glob_sel_jobid = lbhand.getListcellItemLabel(isel,6);

		showBOMMetadata(global_selected_bom);
		showBuildItems(global_selected_bom);
		bval = (global_sel_bom_status.equals("COMMIT")) ? true : false;
		toggleBuildsButts(bval);

		glob_commit_sql = ""; // clear prev commit-bom sqlstm
		global_selected_build = ""; // clear prev selected build
		build_details_grid.setVisible(false);
	}
}
bomclkier = new bomslbClick();

void showBOMList()
{
	scht = kiboo.replaceSingleQuotes(searhtxt_tb.getValue().trim());
	sdate = kiboo.getDateFromDatebox(startdate);
    edate = kiboo.getDateFromDatebox(enddate);
	Listbox newlb = lbhand.makeVWListbox_Width(boms_holder, bomslb_headers, "boms_lb", 10);

	sqlstm = "select sri.origid,sri.customer_name,sri.createdate,sri.createdby,sri.bomstatus," + 
	"sri.bomcategory,sri.job_id from stockrentalitems sri ";
	wherestr = "where sri.createdate between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' ";

	if(!scht.equals("")) wherestr = "left join stockrentalitems_det srid on srid.parent_id = sri.origid " + 
		"where srid.asset_tag like '%" + scht + "%' group by sri.origid,sri.customer_name,sri.createdate," + 
		"sri.createdby,sri.bomstatus,sri.bomcategory,sri.job_id";

	sqlstm += wherestr;

	screcs = sqlhand.gpSqlGetRows(sqlstm);
	if(screcs.size() == 0) return;
	newlb.setRows(30);
	newlb.setMold("paging");
	newlb.addEventListener("onSelect", bomclkier);
	ArrayList kabom = new ArrayList();

	for(dpi : screcs)
	{
		kabom.add(BOM_PREFIX + dpi.get("origid").toString());
		kabom.add(dpi.get("createdate").toString().substring(0,10));
		//custr = getFocus_CustomerName(dpi.get("customerid"));
		kabom.add(kiboo.checkNullString(dpi.get("customer_name")));
		kabom.add(kiboo.checkNullString(dpi.get("createdby")));
		kabom.add(kiboo.checkNullString(dpi.get("bomstatus")));
		kabom.add(kiboo.checkNullString(dpi.get("bomcategory")));
		jid = (dpi.get("job_id") == null) ? "" : dpi.get("job_id").toString();
		kabom.add(jid);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}

void showBuild_metadata(String ibui)
{
	ris = getRentalItems_build(ibui);
	if(ris == null)
	{
		guihand.showMessageBox("ERR: Cannot access rental-item builds table..");
		return;
	}
	clearBuilds_items();

	Object[] fls = {
	m_asset_tag, m_description, m_cpu, m_ram, m_hdd, m_gfxcard, m_vgacable,
	m_mouse, m_keyboard, m_poweradaptor, m_misc, m_monitor, m_battery,
	coa1, coa2, coa3, coa4,
	m_ram2, m_ram3, m_ram4,
	m_hdd2, m_hdd3, m_hdd4,
	m_grade, osversion, offapps };

	String[] fln = {
	"asset_tag", "description", "cpu", "ram", "hdd", "gfxcard", "vgacable",
	"mouse", "keyboard", "poweradaptor", "misc", "monitor", "battery",
	"coa1", "coa2", "coa3", "coa4",
	"ram2", "ram3", "ram4",
	"hdd2", "hdd3", "hdd4",
	"grade", "osversion", "offapps" };

	populateUI_Data(fls,fln,ris);
}

Object[] builds_headers = 
{
	new listboxHeaderWidthObj("##",true,"60px"),
	new listboxHeaderWidthObj("Builds",true,"70px"),
	new listboxHeaderWidthObj("AssetTag",true,"80px"),
	new listboxHeaderWidthObj("Grd",true,"40px"),
	new listboxHeaderWidthObj("Description",true,""),
	new listboxHeaderWidthObj("origid",false,""),
};

class buildsClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		try {
		//doFunc(updbuild_b); // update prev build-items if any
		isel = event.getReference();
		global_selected_build = lbhand.getListcellItemLabel(isel,5);
		bln = lbhand.getListcellItemLabel(isel,0);
		global_sel_buildtype = lbhand.getListcellItemLabel(isel,1);
		buildno_lbl.setValue(bln + " " + global_sel_buildtype);

		// toggle parts-selection butts TODO later need to modi to cater SERVER
		// 26/08/2013: monitor type added
		blty = (global_sel_buildtype.equals("DESKTOP")) ? 1 : 2;
		if(global_sel_buildtype.equals("MONITOR")) blty = 3;

		togglePartsButtons(blty);
		showBuild_metadata(global_selected_build);
		build_details_grid.setVisible(true);

		} catch (Exception e) {}
	}
}
buidlsclik = new buildsClick();

void showBuildItems(String ibid)
{
	Listbox newlb = lbhand.makeVWListbox_Width(builds_holder, builds_headers, "builds_lb", 10);
	sqlstm = "select origid,bomtype,grade,description,asset_tag from stockrentalitems_det where parent_id=" + ibid;
	screcs = sqlhand.gpSqlGetRows(sqlstm);
	if(screcs.size() == 0) return;
	newlb.setMold("paging");
	newlb.setMultiple(true);
	newlb.setCheckmark(true);
	newlb.addEventListener("onSelect", buidlsclik);
	lncnt = 1;
	ArrayList kabom = new ArrayList();
	for(dpi : screcs)
	{
		kabom.add(lncnt.toString() + ".");
		kabom.add(dpi.get("bomtype"));
		kabom.add( kiboo.checkNullString(dpi.get("asset_tag")) );
		kabom.add(kiboo.checkNullString(dpi.get("grade")));
		kabom.add(kiboo.checkNullString(dpi.get("description")));
		kabom.add(dpi.get("origid").toString());
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		lncnt++;
		kabom.clear();
	}
}

