import org.victor.*;

// Asset related funcs for contractBillingTrack_v1.zul

void showAssetMetadata(String iwhat)
{
	rc = getLCEquips_rec(iwhat);
	glob_sel_assetrec = rc;

	Object[] metflds = {
	m_asset_tag,m_brand,m_model,m_battery,m_hdd,m_hdd2,m_hdd3,m_hdd4,m_ram,m_ram2,m_ram3,m_ram4,
	m_gfxcard,m_mouse,m_keyboard,m_monitor,m_poweradaptor,coa1,coa2,coa3,coa4,m_misc,m_cust_location,
	m_type,osversion,offapps,m_serial_no, m_rm_month
	};

	String[] metfnms = {
	"asset_tag","brand","model","battery","hdd","hdd2","hdd3","hdd4","ram","ram2","ram3","ram4",
	"gfxcard","mouse","keyboard","monitor","poweradaptor","coa1","coa2","coa3","coa4",
	"remarks","cust_location",
	"type","osversion","offapps","serial_no", "RM_Month"
	};
	
	populateUI_Data(metflds, metfnms, rc);
	/*
	for(i=0; i<metflds.length; i++)
	{
		if(metflds[i] instanceof Textbox)
		{
			k = (rc.get(metfnms[i]) instanceof Double) ? nf2.format(rc.get(metfnms[i])) : kiboo.checkNullString(rc.get(metfnms[i]));
			metflds[i].setValue(k);
		}
		if(metflds[i] instanceof Listbox) lbhand.matchListboxItems(metflds[i], kiboo.checkNullString(rc.get(metfnms[i])) );
	}
	*/
	assbom_holder.setVisible(true);
}

Object[] asslb_hds =
{
	new listboxHeaderWidthObj("AssetTag",true,""),
	new listboxHeaderWidthObj("S/Num",true,""),
	new listboxHeaderWidthObj("Brand",true,""),
	new listboxHeaderWidthObj("Model",true,""),
	new listboxHeaderWidthObj("Type",true,""),
	new listboxHeaderWidthObj("GCN",true,"50px"),
	new listboxHeaderWidthObj("origid",false,""),
};

class assClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		glob_selected_ass_li = isel;
		glob_selected_ass = lbhand.getListcellItemLabel(isel,6); // asset's origid always last TODO
		glob_selected_asstag = lbhand.getListcellItemLabel(isel,0);
		showAssetMetadata(glob_selected_ass);
	}
}
assclicko = new assClick();

void showAssets(String iwhat)
{
	Listbox newlb = lbhand.makeVWListbox_Width(lcasset_holder, asslb_hds, "lcassets_lb", 20);
	sqlstm = "select origid,asset_tag,brand,model,type,serial_no,gcn_id from rw_lc_equips " +
	"where lc_parent=" + iwhat + " order by asset_tag";

	asrs = sqlhand.gpSqlGetRows(sqlstm);
	if(asrs.size() == 0) return;
	newlb.setMold("paging");
	newlb.setMultiple(true);
	newlb.setCheckmark(true);
	newlb.addEventListener("onSelect", assclicko);
	ArrayList kabom = new ArrayList();
	String[] fl = { "asset_tag", "serial_no", "brand", "model", "type", "gcn_id", "origid" };
	for(d : asrs)
	{
		popuListitems_Data(kabom,fl,d);
		/*
		kabom.add( kiboo.checkNullString(d.get("asset_tag")) );
		kabom.add( kiboo.checkNullString(d.get("serial_no")) );
		kabom.add( kiboo.checkNullString(d.get("brand")) );
		kabom.add( kiboo.checkNullString(d.get("model")) );
		kabom.add( kiboo.checkNullString(d.get("type")) );
		kabom.add( (d.get("gcn_id") == null) ? "" : d.get("gcn_id").toString() );
		kabom.add( d.get("origid").toString() );
		*/
		/*
		if(krem.length() > 40) krem = krem.substring(0,40) + "..";
		kabom.add(krem);
		*/
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	//updateFoundStuff_labels(lc_assetsfound_lbl,lcassets_lb, " asset/item(s) found");
	//glob_selected_ass = ""; // reset
	//assetworkarea.setVisible(false);
}

// ROC/LC assets funcs
void assFunc(Object iwhat)
{
	itype = iwhat.getId();
	todaydate =  kiboo.todayISODateTimeString();
	refresh_wass = false;
	msgtext = sqlstm = "";

	if(itype.equals("newasset_b"))
	{
		if(glob_selected_lc.equals("")) return;
		sqlstm = "insert into rw_lc_equips (asset_tag,serial_no,lc_parent) values " +
		"('NEW ASSET','NO SERIAL'," + glob_selected_lc + ")";
		refresh_wass = true;
	}

	if(itype.equals("updasset_b"))
	{
		if(glob_selected_ass.equals("")) return;
		
		Object[] inpflds = {
		m_asset_tag, m_brand, m_model, m_battery, m_hdd, m_hdd2, m_hdd3, m_hdd4,
		m_ram, m_ram2, m_ram3, m_ram4, m_gfxcard, m_mouse, m_keyboard, m_monitor,
		coa1, coa2, coa3, coa4, osversion, offapps, m_misc,
		m_type, m_cust_location, m_poweradaptor, m_serial_no, m_rm_month
		};

		inpdat = getString_fromUI(inpflds);
		try { k = Float.parseFloat(inpdat[27]); } catch (Exception e) { inpdat[27] = "0"; } // chk RM/month is truly numba

		sqlstm = "update rw_lc_equips set asset_tag='" + inpdat[0] + "', brand='" + inpdat[1] + "', model='" + inpdat[2] +"'," +
		"battery='" + inpdat[3] + "', hdd='" + inpdat[4] + "', hdd2='" + inpdat[5] + "', hdd3='" + inpdat[6] + "', hdd4='" + inpdat[7] + "'," +
		"ram='" + inpdat[8] + "', ram2='" + inpdat[9] + "', ram3='" + inpdat[10] + "', ram4='" + inpdat[11] + "'," +
		"gfxcard='" + inpdat[12] + "', mouse='" + inpdat[13] + "', keyboard='" + inpdat[14] + "', monitor='" + inpdat[15] + "'," +
		"coa1='" + inpdat[16] + "', coa2='" + inpdat[17] + "', coa3='" + inpdat[18] + "', coa4='" + inpdat[19] + "'," +
		"osversion='" + inpdat[20] + "', offapps='" + inpdat[21] + "', remarks='" + inpdat[22] + "', type='" + inpdat[23] + "'," + 
		"cust_location='" + inpdat[24] + "', poweradaptor='" + inpdat[25] + "', serial_no='" + inpdat[26] + "', rm_month=" + inpdat[27] +
		" where origid=" + glob_selected_ass;

		refresh_wass = true;
	}

	if(itype.equals("remasset_b"))
	{
		if(glob_selected_ass.equals("")) return;
		/*
		if(useraccessobj.accesslevel == 9)
		{
			if (Messagebox.show("This will be a hard delete..", "Are you sure?", 
			Messagebox.YES | Messagebox.NO, Messagebox.QUESTION) !=  Messagebox.YES) return;

			deleteLCAssets();

			glob_sel_assetrec = null;
			glob_selected_ass = "";
			assbom_holder.setVisible(false);
			refresh_wass = true;
		}
		else
		msgtext = "Higher access level required to remove-asset from LC/ROC";
		*/
			if (Messagebox.show("This will be a hard delete..", "Are you sure?", 
			Messagebox.YES | Messagebox.NO, Messagebox.QUESTION) !=  Messagebox.YES) return;

			deleteLCAssets();

			glob_sel_assetrec = null;
			glob_selected_ass = "";
			assbom_holder.setVisible(false);
			refresh_wass = true;
	}

	if(itype.equals("repasspop_b"))
	{
		clearReplaceAssetPopup();
		currasst_lbl.setValue(glob_selected_asstag);
		replaceasset_pop.open(iwhat);
	}

	// 13/01/2014: no need any checking for now. Just let 'em replace anything
	if(itype.equals("repasset_b")) // replace assets - TODO a bit complex, need to link-up with BOM or something
	{
		if(glob_selected_ass.equals("")) return;
		ks = kiboo.replaceSingleQuotes(r_asset_tag.getValue().trim());
		if(ks.equals("")) return;
		replaceasset_pop.close();
		replaceLCAsset(); // actually doing it
		glob_selected_ass = "";
		clearReplaceAssetPopup();
	}

	if(itype.equals("assimpbom_b"))
	{
		if(glob_selected_lc.equals("")) return;
		if(glob_sel_importbom.equals("")) return; // glob_sel_importbom def in: TODO
		importBOMToLC(glob_selected_lc,glob_sel_importbom);
	}

	if(itype.equals("markcollect_b")) // mark for collection
	{
		try { if(lcassets_lb.getSelectedCount() == 0) return; } catch (Exception e) { return; }
		astgs = "";
		for(d : lcassets_lb.getSelectedItems())
		{
			atg = lbhand.getListcellItemLabel(d,0);
			gcni = lbhand.getListcellItemLabel(d,5); // gcn-id must be blank
			if( !atg.equals("") && gcni.equals("") ) astgs += atg + "\n";
		}
		gcntrans_lbl.setValue(astgs);
		gcn_trans_pop.open(iwhat);
	}

	if(itype.equals("svgcntrans_b")) // actually saving selected assets for collection - gcn-transient-table
	{
		try { if(lcassets_lb.getSelectedCount() == 0) return; } catch (Exception e) { return; }
		if(glob_sel_lc_str.equals(""))
		{
			msgtext = "To save transient-asset-tags for collection, LC-id must be available.";
		}
		else
		{
			for(d : lcassets_lb.getSelectedItems())
			{
				atg = lbhand.getListcellItemLabel(d,0);
				asn = lbhand.getListcellItemLabel(d,1);
				if(atg.equals("")) continue;

				gcni = lbhand.getListcellItemLabel(d,5); // gcn-id must be blank to be saved in transient-table
				if(gcni.equals(""))
				{
					itmd =
					"[" + lbhand.getListcellItemLabel(d,4) + "] " +
					lbhand.getListcellItemLabel(d,2) + " " + lbhand.getListcellItemLabel(d,3);

					// TODO save fc6-customer-id
					sqlstm += "insert into rw_gcn_transient (lc_id,serial_no,asset_tag,item_desc) values " +
					"('" + glob_sel_lc_str + "','" + asn + "','" + atg + "','" + itmd + "');";
				}
			}
			if(!sqlstm.equals("")) msgtext = "Assets saved to GCN/O transient-table..";
		}
	}

	if(itype.equals("impDOass_b")) // import from FC6 DO
	{
		if(glob_selected_lc.equals("")) return;
		impFC6_DO_Assets(glob_selected_lc,1);
	}

	if(itype.equals("flexi_impDOass_b"))
	{
		if(glob_selected_lc.equals("")) return;
		impFC6_DO_Assets(glob_selected_lc,2);
	}

	if(itype.equals("getfc6assdet_b")) // try to suck asset-details from FC6
	{
		if(glob_selected_ass.equals("")) return;
		suckFCAssetDetails(glob_selected_ass, glob_selected_asstag);
	}

	if(itype.equals("sedutcontc_b")) // try suck from contract-care equips listing as of 20/02/2014
	{
		if(glob_selected_lc.equals("")) return;
		actualSuckContractcare();
	}

	if(itype.equals("copyassflc_b")) // copy assets from another LC
	{
		if(glob_selected_lc.equals("")) return;
		olc = kiboo.replaceSingleQuotes( copylcid.getValue().trim() );
		if(olc.equals("")) return;
		sqlr = "select origid from rw_lc_records where lc_id='" + olc + "'";
		rc = sqlhand.gpSqlFirstRow(sqlr);
		if(rc != null)
		{ 
			copyAssetsFromLC(glob_selected_lc, rc.get("origid").toString() );
			add_RWAuditLog(LC_PREFIX + glob_selected_lc, "", "Copy assets from LC " + olc , useraccessobj.username);
		}
	}

	if(!sqlstm.equals("")) sqlhand.gpSqlExecuter(sqlstm);
	if(refresh_wass) showAssets(glob_selected_lc);
	if(!msgtext.equals("")) guihand.showMessageBox(msgtext);
}

void copyAssetsFromLC(String idest, String isrc)
{
	sqlstm = "insert into rw_lc_equips (" + 
	"lc_parent,asset_tag,serial_no,type,brand,model,capacity,color,coa1,ram,hdd,others," +
	"cust_location,qty,replacement,replacement_date,rma_qty,remarks,collected," +
	"RM_Asset,RM_Month,latest_replacement,roc_no,do_no,cn_no,asset_status," +
	"coa2,coa3,coa4,ram2,ram3,ram4,hdd2,hdd3,hdd4," +
	"osversion,offapps,poweradaptor,battery,estatus,gfxcard,mouse,keyboard,monitor) " +
	"select " + idest + ",asset_tag,serial_no,type,brand,model,capacity,color,coa1,ram,hdd,others," +
	"cust_location,qty,replacement,replacement_date,rma_qty,remarks,collected," +
	"RM_Asset,RM_Month,latest_replacement,roc_no,do_no,cn_no,asset_status," +
	"coa2,coa3,coa4,ram2,ram3,ram4,hdd2,hdd3,hdd4," +
	"osversion,offapps,poweradaptor,battery,estatus,gfxcard,mouse,keyboard,monitor " +
	"from rw_lc_equips WHERE lc_parent=" + isrc;

	sqlhand.gpSqlExecuter(sqlstm);
	showAssets(glob_selected_lc);
}

void actualSuckContractcare()
{
	sqlstm = "";
	kx = contcareqs_lb.getItems().toArray();
	for(i=0;i<kx.length;i++)
	{
		atg = kiboo.replaceSingleQuotes( lbhand.getListcellItemLabel(kx[i],0) );
		sqlstm += "insert into rw_lc_equips (lc_parent,asset_tag) values (" + glob_selected_lc + ",'" + atg + "');";
	}

	if(!sqlstm.equals(""))
	{
		sqlhand.gpSqlExecuter(sqlstm);
		showAssets(glob_selected_lc);
		contcarepop.close();
		contcareqs_lb.setParent(null);
	}
}

Object[] ccqhds =
{
	new listboxHeaderWidthObj("AssetTag",true,""),
	new listboxHeaderWidthObj("Model",true,""),
};

// contractcare equips listing imported as of 20/02/2014
void impContractcare()
{
//
	Listbox newlb = lbhand.makeVWListbox_Width(ccareqs_holder, ccqhds, "contcareqs_lb", 20);
	lcn = kiboo.replaceSingleQuotes( cclcno_tb.getValue().trim() );
	if(lcn.equals("")) return;
	sqlstm = "select ca.asset_tag, (select name from mr001 where code2 = ca.asset_tag) as equip_name " +
	"from contractcare_eqs ca where ca.lc_no='" + lcn + "';";
	drs = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(drs.size() == 0) return;
	newlb.setMold("paging");
	//newlb.setMultiple(true);
	//newlb.setCheckmark(true);
	//newlb.addEventListener("onSelect", new assClick());
	ArrayList kabom = new ArrayList();
	for(d : drs)
	{
		kabom.add( kiboo.checkNullString(d.get("asset_tag")) );
		kabom.add( kiboo.checkNullString(d.get("equip_name")) );
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}

void suckFCAssetDetails(String iasid, String iastg)
{
	if(lcassets_lb.getSelectedCount() > 1) multiSuckFCAssetDetails();

	sqlstm = "select m.code, u.brandyh, u.modelyh, u.hddsizeyh,u.itemtypeyh, u.remarkyh, u.coa1yh, u.coa2yh," +
	"u.coa1keyyh, u.coa2keyyh, u.ramsizeyh from mr001 m left join u0001 u on u.extraid = m.masterid " +
	"where m.code2='" + iastg + "'";

	d = sqlhand.rws_gpSqlFirstRow(sqlstm);
	if(d == null) return;

	sql2 = "update rw_lc_equips set serial_no='" + kiboo.checkNullString(d.get("code")) + "'," +
	"brand='" + kiboo.checkNullString(d.get("brandyh")) + "'," +
	"model='" + kiboo.checkNullString(d.get("modelyh")) + "'," +
	"type='" + kiboo.checkNullString(d.get("itemtypeyh")) + "'," +
	"hdd='" + kiboo.checkNullString(d.get("hddsizeyh")) + "'," +
	"ram='" + kiboo.checkNullString(d.get("ramsizeyh")) + "'," +
	"osversion='" + kiboo.checkNullString(d.get("coa1yh")) + "'," +
	"offapps='" + kiboo.checkNullString(d.get("coa2yh")) + "'," +
	"coa1='" + kiboo.checkNullString(d.get("coa1keyyh")) + "'," +
	"coa2='" + kiboo.checkNullString(d.get("coa2keyyh")) + "' " +
	"where origid=" + iasid;

	sqlhand.gpSqlExecuter(sql2);
	showAssetMetadata(iasid);
}

// 20/02/2014: multi-select grab asset-spec from FC6
void multiSuckFCAssetDetails()
{
	kx = lcassets_lb.getSelectedItems().toArray();
	sqlstm = "";
	for(i=0;i<kx.length;i++)
	{
		atg = lbhand.getListcellItemLabel(kx[i],0).trim();
		oid = lbhand.getListcellItemLabel(kx[i],6);

		fst = "select m.code, u.brandyh, u.modelyh, u.hddsizeyh,u.itemtypeyh, u.remarkyh, u.coa1yh, u.coa2yh," +
		"u.coa1keyyh, u.coa2keyyh, u.ramsizeyh from mr001 m left join u0001 u on u.extraid = m.masterid " +
		"where ltrim(rtrim(m.code2))='" + atg + "'";

		d = sqlhand.rws_gpSqlFirstRow(fst);

		if(d != null)
		{
			sqlstm += "update rw_lc_equips set serial_no='" + kiboo.checkNullString(d.get("code")) + "'," +
				"brand='" + kiboo.checkNullString(d.get("brandyh")) + "'," +
				"model='" + kiboo.checkNullString(d.get("modelyh")) + "'," +
				"type='" + kiboo.checkNullString(d.get("itemtypeyh")) + "'," +
				"hdd='" + kiboo.checkNullString(d.get("hddsizeyh")) + "'," +
				"ram='" + kiboo.checkNullString(d.get("ramsizeyh")) + "'," +
				"osversion='" + kiboo.checkNullString(d.get("coa1yh")) + "'," +
				"offapps='" + kiboo.checkNullString(d.get("coa2yh")) + "'," +
				"coa1='" + kiboo.checkNullString(d.get("coa1keyyh")) + "'," +
				"coa2='" + kiboo.checkNullString(d.get("coa2keyyh")) + "' " +
				"where origid=" + oid + ";";
		}
	}

	if(!sqlstm.equals(""))
	{
		sqlhand.gpSqlExecuter(sqlstm);
		showAssets(glob_selected_lc);
	}
}

// Log asset-record by LC no.
void logAssetRecord(String ilc, String iass)
{
	//alert("lc: " + ilc + " :: asset: " + iass);
	Object[] inpflds = { m_asset_tag, m_brand, m_model, m_battery, m_hdd, m_hdd2, m_hdd3, m_hdd4,
	m_ram, m_ram2, m_ram3, m_ram4, m_gfxcard, m_mouse, m_keyboard, m_monitor, m_poweradaptor,
	coa1, coa2, coa3, coa4, m_misc, m_type, m_cust_location, osversion, offapps, m_serial_no
	};

	String[] hds = { "REPLACED: astg:", ", brnd:", ", mdel:", ", btry:", 
	", hdd1:", ", hdd2:", ", hdd3:", ", hdd4:", ", ram1:",", ram2:",", ram3:",", ram4:", ", gfxc:",
	", mse:", ", kyb:", ", moni:", ", pwra:", ", coa1:", ", coa2:", ", coa3:", ", coa4:", ", misc:",
	", tpe:", ", loc:", ", osv:", ", ofa:", ", snm:"
	};

	String[] inpdat = new String[inpflds.length];
	lgstr = "";

	for(i=0;i<inpflds.length;i++)
	{
		if(inpflds[i] instanceof Textbox) inpdat[i] = kiboo.replaceSingleQuotes( inpflds[i].getValue().trim() );
		if(inpflds[i] instanceof Listbox) inpdat[i] = inpflds[i].getSelectedItem().getLabel();
		lgstr += hds[i] + inpdat[i];
	}

	add_RWAuditLog(LC_PREFIX + ilc, inpdat[0], lgstr, useraccessobj.username);
}

// Do checks and so on to replace asset
/// TODO 13/01/2014: later put in all these checks. for now, free for all
void replaceLCAsset()
{
	if(glob_selected_ass.equals("")) return;
	logAssetRecord(glob_selected_lc,glob_selected_ass); // save existing asset-rec in audit-log

	Object[] inpflds =
	{ r_asset_tag, r_brand, r_model, r_battery, r_hdd, r_hdd2, r_hdd3, r_hdd4,
	r_ram, r_ram2, r_ram3, r_ram4, r_gfxcard, r_mouse, r_keyboard, r_monitor,
	r_coa1, r_coa2, r_coa3, r_coa4, r_osversion, r_offapps, r_misc,
	r_type, r_cust_location, r_poweradaptor, r_serial_no
	};

	inpdat = getString_fromUI(inpflds);

	sqlstm = "update rw_lc_equips set asset_tag='" + inpdat[0] + "', brand='" + inpdat[1] + "', model='" + inpdat[2] +"'," +
	"battery='" + inpdat[3] + "', hdd='" + inpdat[4] + "', hdd2='" + inpdat[5] + "', hdd3='" + inpdat[6] + "', hdd4='" + inpdat[7] + "'," +
	"ram='" + inpdat[8] + "', ram2='" + inpdat[9] + "', ram3='" + inpdat[10] + "', ram4='" + inpdat[11] + "'," +
	"gfxcard='" + inpdat[12] + "', mouse='" + inpdat[13] + "', keyboard='" + inpdat[14] + "', monitor='" + inpdat[15] + "'," +
	"coa1='" + inpdat[16] + "', coa2='" + inpdat[17] + "', coa3='" + inpdat[18] + "', coa4='" + inpdat[19] + "'," +
	"osversion='" + inpdat[20] + "', offapps='" + inpdat[21] + "', remarks='" + inpdat[22] + "', type='" + inpdat[23] + "'," + 
	"cust_location='" + inpdat[24] + "', poweradaptor='" + inpdat[25] + "', serial_no='" + inpdat[26] + "' where origid=" + glob_selected_ass;

	sqlhand.gpSqlExecuter(sqlstm);
	showAssets(glob_selected_lc);
/*
	// chk if to-be-replaced asset-tag exist
	rstkc = kiboo.replaceSingleQuotes(r_asset_tag.getValue().trim());
	tbr_ass = getStockItem_rec(rstkc);
	if(tbr_ass == null)
	{
		guihand.showMessageBox("Sorry, " + rstkc + " does not exist in the system..");
		return;
	}
	// chk to-be-replaced asset type, must be same as selected asset
	// TODO put in codes in rental_items.zul to set smd.item_type
	styp = m_type.getSelectedItem().getLabel();
	tbr_type = kiboo.checkNullString( tbr_ass.get("item_type") );
	if(!styp.equals(tbr_type))
	{
		guihand.showMessageBox("Problem, you're trying to replace an asset of type " + tbr_type + " to " + styp);
		return;
	}
	// check new-asset parts form
	// audit-log: current asset's record
	// save current-asset to gcn-transient (to collect back)
	// replace new asset's record - link to LC-id
*/

}

// Clear those fields in replace-asset popup
void clearReplaceAssetPopup()
{
	Object[] metaflds = {
	r_asset_tag, r_brand, r_model, r_cust_location, r_hdd, r_ram, r_hdd2, r_ram2,
	r_hdd3,r_ram3,r_hdd4,r_ram4,r_gfxcard,r_battery,r_mouse,r_keyboard,r_monitor,
	r_poweradaptor,r_coa1,r_coa3,r_coa2,r_coa4,r_misc,
	r_type,r_osversion,r_offapps, r_serial_no
	};

	clearUI_Field(metaflds);
}

// Delete assets from LC, reset SMD.lc_id
void deleteLCAssets()
{
	asts = lcassets_lb.getSelectedItems().toArray();
	sels = iorig = "";

	for(i=0;i<asts.length;i++)
	{
		sels += "'" + lbhand.getListcellItemLabel(asts[i],0) + "',";
		iorig += lbhand.getListcellItemLabel(asts[i],6) + ",";
		lcassets_lb.removeChild(asts[i]);
	}

	try {
	sels = sels.substring(0,sels.length()-1);
	iorig = iorig.substring(0,iorig.length()-1);
	} catch (Exception e) {}

	sqlstm = "delete from rw_lc_equips where origid in (" + iorig + ");";
	sqlstm += "update stockmasterdetails set lc_id=null where stock_code in (" + sels + ");"; // null smd.lc_id for recs-sync
	sqlhand.gpSqlExecuter(sqlstm);
}

// import items from FC6 DO
void impFC6_DO_Assets(String ilc, int itype)
{
	mylb = null;

	switch(itype)
	{
		case 1:
			mylb = impfc6dolb; // LBs hardcoded in contractBillingTrack_v1.zul
			break;
		case 2:
			mylb = flximpfc6dolb;
			break;
	}

	String[] k = new String[11];
	sqlstm = "";
	kx = mylb.getItems().toArray();
	for(i=0;i<kx.length;i++)
	{
		lx = kx[i];
		for(j=0;j<11;j++)
		{
			k[j] = kiboo.replaceSingleQuotes( lbhand.getListcellItemLabel(lx,j) );
		}
		sqlstm += "insert into rw_lc_equips (asset_tag,serial_no,brand,model,type,color,hdd,ram,lc_parent,cust_location) values " +
		"('" + k[0] + "', '" + k[1] + "','" + k[3] + "','" + k[4] + "','" + k[5] + "'," +
		"'" + k[6] + "','" + k[7] + "','" + k[8] + "'," + ilc + ",'" + k[10] + "');";
	}

	if(!sqlstm.equals(""))
	{
		sqlhand.gpSqlExecuter(sqlstm);
		showAssets(ilc);
		importdoassets_pop.close();
		fleximportfc6_pop.close();
	}
}

// Actually importing BOM's builds into LC
// TODO 29/08/2013 just assume BOM is VERIFIED, but still need do checks later
void importBOMToLC(String ilcid, String ibid)
{
	pmsg = "Processing BOM import";
	ierr = 0; blnkastg = 0;
	assettags = "";

	sqlstm = 
	"select srid.asset_tag, srid.bomtype, smd.supplier_part_number as serial_no," +
	"smd.brandname as brand, smd.description as model, " +
	"srid.ram, srid.ram2, srid.ram3, srid.ram4," +
	"srid.hdd, srid.hdd2, srid.hdd3, srid.hdd4, srid.monitor," +
	"srid.battery, srid.poweradaptor, srid.mouse, srid.keyboard, srid.gfxcard, srid.misc," +
	"srid.osversion, srid.offapps, srid.coa1, srid.coa2, srid.coa3, srid.coa4 " +
	"from stockrentalitems_det srid " +
	"left join stockmasterdetails smd on smd.stock_code=srid.asset_tag " +
	"where parent_id=" + ibid;

	rcs = sqlhand.gpSqlGetRows(sqlstm);

	if(rcs.size() == 0)
	{
		pmsg += "\nNothing to import..";
		ierr++;
	}

	for(d : rcs)
	{
		astg = kiboo.checkNullString(d.get("asset_tag")).trim();
		if(astg.equals("")) blnkastg++;
		else
		{
			pmsg += "\n\t" + astg;
			ast = assetLinkToLC(astg);
			switch(ast)
			{
				case 0:
					pmsg += " NOT FOUND in stock-master";
					ierr++;
					break;
				case 1:
					pmsg += " OK";
					assettags += "'" + astg + "',";
					break;
				case 2:
					pmsg += " ALREADY LINKED to ";
					lnlc = assetExistInLC(astg);
					if(!lnlc.equals(""))
					{
						pmsg += " record " + lnlc;
					}
					ierr++;
					break;
			}
		}
	}

	if(blnkastg > 0)
		pmsg += "\nERR: Found " + blnkastg.toString() + " blank build(s)/asset-tag";

	if(ierr == 0 && blnkastg == 0) // if no error found - can insert LC-id into asset
	{
		usqlstm = "";

		for(d : rcs) // insert assets into rw_leaseequipments
		{
			btype = "DT";
			if( kiboo.checkNullString(d.get("bomtype")).equals("NOTEBOOK") ) btype = "NB";
			if( kiboo.checkNullString(d.get("bomtype")).equals("MONITOR") ) btype = "MT";
			
			usqlstm +=
			"insert into rw_lc_equips (lc_parent,asset_tag,serial_no,type,brand,model,bom_id," +
			"ram,ram2,ram3,ram4,hdd,hdd2,hdd3,hdd4,battery,poweradaptor,gfxcard," +
			"mouse,keyboard,osversion,offapps,coa1,coa2,coa3,coa4,monitor) values " +
			"(" + ilcid + ",'" + d.get("asset_tag") + "','" + kiboo.checkNullString(d.get("serial_no")) + "'," +
			"'" + btype + "','" + kiboo.checkNullString(d.get("brand")) + "'," + 
			"'" + kiboo.checkNullString(d.get("model")) + "'," + ibid +

			",'" + kiboo.checkNullString(d.get("ram")) + "','" + kiboo.checkNullString(d.get("ram2")) + "','" + 
			kiboo.checkNullString(d.get("ram3")) + "','" + kiboo.checkNullString(d.get("ram4")) + "','" +
			kiboo.checkNullString(d.get("hdd")) + "','" + kiboo.checkNullString(d.get("hdd2")) + "','" +
			kiboo.checkNullString(d.get("hdd3")) + "','" + kiboo.checkNullString(d.get("hdd4")) + "','" +
			kiboo.checkNullString(d.get("battery")) + "','" + kiboo.checkNullString(d.get("poweradaptor")) + "','" +
			kiboo.checkNullString(d.get("gfxcard")) + "','" + kiboo.checkNullString(d.get("mouse")) + "','" +
			kiboo.checkNullString(d.get("keyboard")) + "','" + kiboo.checkNullString(d.get("osversion")) + "','" +
			kiboo.checkNullString(d.get("offapps")) + "','" + kiboo.checkNullString(d.get("coa1")) + "','" +
			kiboo.checkNullString(d.get("coa2")) + "','" + kiboo.checkNullString(d.get("coa3")) + "','" +
			kiboo.checkNullString(d.get("coa4")) + "','" + kiboo.checkNullString(d.get("monitor")) + "')";
		}

		try { assettags = assettags.substring(0,assettags.length()-1); } catch (Exception e) {}

		// update smd.lc_id (every asset-tag)
		usqlstm += "update stockmasterdetails set lc_id=" + ilcid + " where stock_code in (" + assettags + ");";
		// update stockrentalitems.lc_id (BOM main rec)		
		usqlstm += "update stockrentalitems set lc_id=" + ilcid + " where origid=" + ibid;

		//pmsg += "\n\n" + usqlstm;
		pmsg += "\n\nBOM's build(s) imported into LC" + ilcid;

		sqlhand.gpSqlExecuter(usqlstm);
		showAssets(ilcid); // refresh
	}

	importbom_stat_lbl.setValue(pmsg);
	importbom_statpop.open(assimpbom_b);
}

