import org.victor.*;

// itype: 1=butts, 2=fields, 3=update-items-details
void toggButts(int itype, boolean iwhat)
{
	Object[] bts1 = { newitm_b, rmitm_b, impgcn_b, impgrn_b, startaudit_b };
	Object[] bts2 = { i_asset_tag, i_serial_num, i_item, i_qty };
	Object[] bts3 = { i_remarks, i_charge, i_charge_amount, upditem_b };
	jd = null;

	switch(itype)
	{
		case 1:
			jd = bts1;
			break;
		case 2:
			jd = bts2;
			break;
		case 3:
			jd = bts3;
			break;
	}

	if(jd != null)
	{
		for(i=0; i<jd.length; i++)
		{
			jd[i].setDisabled(iwhat);
		}
	}
//compaudit_b
}

void showAuditItem_det(Object isel)
{
	i_asset_tag.setValue( lbhand.getListcellItemLabel(isel,0) );
	i_serial_num.setValue( lbhand.getListcellItemLabel(isel,2) );
	i_item.setValue( lbhand.getListcellItemLabel(isel,1) );
	i_qty.setValue( lbhand.getListcellItemLabel(isel,3) );
	grd = lbhand.getListcellItemLabel(isel,5);
	lbhand.matchListboxItems(i_regrade, (grd.equals("X")) ? "SCRAP" : grd);
	i_remarks.setValue( lbhand.getListcellItemLabel(isel,8) );
	cy = lbhand.getListcellItemLabel(isel,6);
	lbhand.matchListboxItems(i_charge, (cy.equals("N")) ? "NO" : "YES");
	i_charge_amount.setValue( lbhand.getListcellItemLabel(isel,7) );
	itemdet_pop.open(isel);
}

void showAuditMeta(String iwhat, String istat)
{
	fillDocumentsList(documents_holder,AUDITITEM_PREFIX,iwhat);
	listAuditItems(iwhat,aitems_holder);

	// Toggle buttons and fields
	bts = false;
	if(istat.equals("WIP") || istat.equals("COMPLETE")) bts = true;
	toggButts(1,bts);
	toggButts(2,bts);
	upt = false;
	if(istat.equals("COMPLETE")) upt = true;
	toggButts(3,upt);

	workarea.setVisible(true);
}

Object[] audhds =
{
	new listboxHeaderWidthObj("ADT",true,"50px"),
	new listboxHeaderWidthObj("Dated",true,"70px"),
	new listboxHeaderWidthObj("User",true,"70px"),
	new listboxHeaderWidthObj("Status",true,"70px"),
	new listboxHeaderWidthObj("Start",true,"80px"),
	new listboxHeaderWidthObj("Complete",true,"80px"),
	new listboxHeaderWidthObj("TempGRN",true,"70px"),
	new listboxHeaderWidthObj("GCN",true,"70px"),
	new listboxHeaderWidthObj("Remarks",true,""),
};

class audidclk implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		selitem = event.getTarget();
		glob_sel_audit = lbhand.getListcellItemLabel(selitem,0);
		remk = lbhand.getListcellItemLabel(selitem,8);
		adtremarks_tb.setValue(remk);
		adtmeta_pop.open(selitem);
		//alert(glob_sel_audit);
	}
}
audidobclik = new audidclk();

class doclike implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		selitm = event.getReference();
		glob_sel_audit = lbhand.getListcellItemLabel(selitm,0);
		glob_sel_status = lbhand.getListcellItemLabel(selitm,3);
		glob_sel_user = lbhand.getListcellItemLabel(selitm,2);
		showAuditMeta(glob_sel_audit, glob_sel_status);
	}
}
doclikor = new doclike();

void listAudits(int itype)
{
	lastlisttype = itype;
	sdate = kiboo.getDateFromDatebox(startdate);
    edate = kiboo.getDateFromDatebox(enddate);
    scht = kiboo.replaceSingleQuotes(searhtxt_tb.getValue()).trim();
	Listbox newlb = lbhand.makeVWListbox_Width(audits_holder, audhds, "audits_lb", 22);

	sqlstm = "select * from rw_qcaudit where datecreated between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' " +
	"order by origid";

	trs = sqlhand.gpSqlGetRows(sqlstm);
	if(trs.size() == 0) return;
	newlb.setMold("paging");
	newlb.addEventListener("onSelect", doclikor);
	ArrayList kabom = new ArrayList();
	for(d : trs)
	{
		kabom.add( d.get("origid").toString() );
		kabom.add( dtf2.format(d.get("datecreated")) );
		kabom.add( d.get("username") );
		kabom.add( d.get("astatus") );
		kabom.add( (d.get("startaudit") == null) ? "" : dtf2.format(d.get("startaudit")) );
		kabom.add( (d.get("completed") == null) ? "" : dtf2.format(d.get("completed")) );
		kabom.add( kiboo.checkNullString(d.get("tempgrn")) );
		kabom.add( (d.get("gcn_no") == null) ? "" : d.get("gcn_no").toString() );
		kabom.add( kiboo.checkNullString(d.get("remarks")) );
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	lbhand.setDoubleClick_ListItems(newlb, audidobclik);
	audits_holder.setVisible(true);
}

Object[] aitmhds =
{
	new listboxHeaderWidthObj("Ass.Tag",true,""),
	new listboxHeaderWidthObj("Item",true,""),
	new listboxHeaderWidthObj("S/Num",true,""),
	new listboxHeaderWidthObj("Qty",true,"30px"),
	new listboxHeaderWidthObj("Status",true,"70px"),
	new listboxHeaderWidthObj("Grade",true,"70px"),
	new listboxHeaderWidthObj("Charge",true,"50px"),
	new listboxHeaderWidthObj("C.Amt",true,"70px"),
	new listboxHeaderWidthObj("Per Item Remarks",true,""),
	new listboxHeaderWidthObj("origid",false,""),
};
aitmorigidpos = 9;

class aitmclk implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		selitm = event.getReference();
		try { glob_sel_audititem = lbhand.getListcellItemLabel(selitm,aitmorigidpos); } catch (Exception e) { glob_sel_audititem = ""; }
	}
}
autditmclk = new aitmclk();

class aitmdclk implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		selitem = event.getTarget();
		glob_sel_audititem = lbhand.getListcellItemLabel(selitem,aitmorigidpos);
		showAuditItem_det(selitem);
	}
}
aitemsdblick = new aitmdclk();

// Can be used by other mods. if iwhere=aitems_holder(main mod holder), then set those clicko-events
void listAuditItems(String iwhat, Div iwhere)
{
	glob_sel_audititem = ""; // reset

	Listbox newlb = lbhand.makeVWListbox_Width(iwhere, aitmhds, "audititems_lb", 22);
	sqlstm = "select origid,item,qty,istatus,regrade,charge,serial_num,asset_tag,remarks,charge_amount " +
	"from rw_qcaudit_items where parent_id=" + iwhat;
	trs = sqlhand.gpSqlGetRows(sqlstm);
	if(trs.size() == 0) return;
	newlb.setMold("paging");
	newlb.setMultiple(true);
	newlb.setCheckmark(true);
	if(iwhere.getId().equals("aitems_holder")) newlb.addEventListener("onSelect", autditmclk);
	ArrayList kabom = new ArrayList();
	for(d : trs)
	{
		kabom.add( kiboo.checkNullString(d.get("asset_tag")) );
		kabom.add( kiboo.checkNullString(d.get("item")) );
		kabom.add( kiboo.checkNullString(d.get("serial_num")) );
		kabom.add( d.get("qty").toString() );
		kabom.add( kiboo.checkNullString(d.get("istatus")) );
		kabom.add( kiboo.checkNullString(d.get("regrade")) );
		kabom.add( (!d.get("charge")) ? "N" : "Y" );
		kabom.add( (d.get("charge_amount") == null) ? "0.00" : nf2.format(d.get("charge_amount")) );
		kabom.add( kiboo.checkNullString(d.get("remarks")) );
		kabom.add( d.get("origid").toString() );
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	if(iwhere.getId().equals("aitems_holder")) lbhand.setDoubleClick_ListItems(newlb, aitemsdblick);
}

Object[] impgcnhds =
{
	new listboxHeaderWidthObj("Asset",true,""),
	new listboxHeaderWidthObj("S/Num",true,""),
	new listboxHeaderWidthObj("Item",true,""),
};

void showGCNItems(Object itb)
{
	ki = kiboo.replaceSingleQuotes( itb.getValue().trim() );
	if(ki.equals("")) return;

	sqlstm = "select items_code,items_desc,items_sn from rw_goodscollection where origid=" + ki;
	r = sqlhand.gpSqlFirstRow(sqlstm);
	if(r.size() == 0) return;

	Listbox newlb = lbhand.makeVWListbox_Width(impgcnitems_holder, impgcnhds, "impgcni_lb", 22);
	newlb.setMold("paging");

	itag = sqlhand.clobToString(r.get("items_code")).split("~");
	idsc = sqlhand.clobToString(r.get("items_desc")).split("~");
	isn = sqlhand.clobToString(r.get("items_sn")).split("~");

	if(itag.length > 0)
	{
		for(i=0; i<itag.length; i++)
		{
			tmtg = "";
			try { tmtg = itag[i]; } catch (Exception e) {}
			tmsn = "";
			try { tmsn = isn[i]; } catch (Exception e) {}
			tmds = "";
			try { tmds = idsc[i]; } catch (Exception e) {}

			ArrayList kabom = new ArrayList();
			kabom.add( tmtg );
			kabom.add( tmsn );
			kabom.add( tmds );
			lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		}
	}
}

Object[] imptgrnhds = 
{
	new listboxHeaderWidthObj("Asset",true,""),
	new listboxHeaderWidthObj("S/Num",true,""),
	new listboxHeaderWidthObj("Item",true,""),
	new listboxHeaderWidthObj("Qty",true,"30px"),
};

void showFCTempGRNitems(Object itb)
{
	ki = kiboo.replaceSingleQuotes( itb.getValue().trim() );
	if(ki.equals("")) return;

	sqlstm = "select p.name as pname, p.code as snum, p.code2 as asstag, iy.qty2 " +
	"from data d left join indta iy on iy.salesid = d.salesoff " +
	"left join mr008 ro on ro.masterid = d.tags6 " +
	"left join mr001 p on p.masterid = d.productcode " +
	"where d.vouchertype=1281 and d.voucherno='" + ki + "';";

	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	Listbox newlb = lbhand.makeVWListbox_Width(imptgrnitems_holder, imptgrnhds, "imptgrni_lb", 22);
	newlb.setMold("paging");
	ArrayList kabom = new ArrayList();
	for(d : r)
	{
		kabom.add( kiboo.checkNullString(d.get("asstag")) );
		kabom.add( kiboo.checkNullString(d.get("snum")) );
		kabom.add( kiboo.checkNullString(d.get("pname")) );
		kabom.add( nf0.format(d.get("qty2")) );
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}


