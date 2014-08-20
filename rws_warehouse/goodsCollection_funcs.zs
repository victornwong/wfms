import org.victor.*;

// Supporting and general-purpose funcs for goodsCollection_v1.zul

/*
itype:
1=submit, cannot update customer or add/remove items
2=completed, cannot save items status anymore
*/ 
void disableButts(int itype, boolean iwhat)
{
	Object[] ibuts = { assigncust_b, updategco_b, additem_b, removeitem_b, imptransient_b, imppartreq_b };
	switch(itype)
	{
		case 1:
			for(i=0;i<ibuts.length;i++)
			{
				ibuts[i].setDisabled(iwhat);
			}
			//importitems_b.setDisabled(iwhat);
			break;
		case 2:
			saveitems_b.setDisabled(iwhat);
			break;
	}
}

void disableItemsTextbox(boolean iwhat)
{
	if(pitems_holder.getFellowIfAny("pickitems_grid") == null) return;
	cds = items_rows.getChildren().toArray();
	if(cds.length < 2) return;
	for(i=1; i<cds.length; i++)
	{
		c1 = cds[i].getChildren().toArray();
		for(j=1;j<5;j++)
		{
			c1[j].setDisabled(iwhat);
		}
	}
}

// Get all asset-tags in items-grid
ArrayList collectAssetTags()
{
	if(pitems_holder.getFellowIfAny("pickitems_grid") == null) return null;
	cds = items_rows.getChildren().toArray();
	if(cds.length < 2) return null;
	ArrayList retv = new ArrayList();
	for(i=1; i<cds.length; i++)
	{
		c1 = cds[i].getChildren().toArray();
		atg = c1[1].getValue().trim();
		if(!atg.equals("")) retv.add(atg);
	}
	return retv;
}

void checkCreateCollectGrid()
{
	if(pitems_holder.getFellowIfAny("pickitems_grid") != null) return;
	grd = new Grid();
	grd.setMold("paging");
	grd.setPageSize(10);
	//grd.setHeight("480px");

	grd.setId("pickitems_grid");
	rws = new org.zkoss.zul.Rows();
	rws.setId("items_rows");
	rws.setParent(grd);

	String[] colhed = { "","Asset Tag","S/N","Description","Col" };
	kcols = new org.zkoss.zul.Columns();
	kcols.setParent(grd);
	for(i=0;i<colhed.length;i++)
	{
		//gpMakeLabel(rwm,"",colhed[i],"");
		kcl = new org.zkoss.zul.Column();
		kcl.setLabel(colhed[i]);
		kcl.setParent(kcols);
	}
/*
	rwm = new org.zkoss.zul.Row();
	rwm.setParent(rws);
	rwm.setStyle("background:#97b83a");
*/
	grd.setParent(pitems_holder);
}

void showGCOMeta(String iwhat)
{
	grc = getGCO_rec(iwhat);
	if(grc == null) return;
	collection_id_lbl.setValue(iwhat);

	String[] fl = { "contact_person", "contact_tel", "contact_email", "location", "collection_notes", "customer_name",
	"lc_id", "transporter", "transp_ref", "tempgrn", "sv_no" };

	Object[] ob = { contact_person, contact_tel, contact_email, location, collection_notes, customername,
	lc_id, g_transporter, g_transp_ref, g_tempgrn, g_sv_no };

	populateUI_Data(ob,fl,grc);

	global_selected_customerid = kiboo.checkNullString( grc.get("fc6_custid") );
	fc6custid_lbl.setValue(global_selected_customerid);

	fillDocumentsList(documents_holder,COLLECTION_PREFIX,iwhat);

	// show the assets to be collected
	if(pitems_holder.getFellowIfAny("pickitems_grid") != null) pickitems_grid.setParent(null);
	checkCreateCollectGrid();

	kst = grc.get("status");
	lkk = lkk2 = false;
	if(!kst.equals("NEW")) lkk = true;
	if(kst.equals("COMPLETE")) lkk2 = true;

	disableButts(1,lkk);
	disableButts(2,lkk2);
	//disableItemsTextbox(lkk);

	ktg = sqlhand.clobToString(grc.get("items_code"));
	if(!ktg.equals(""))
	{
		itag = sqlhand.clobToString(grc.get("items_code")).split("~");
		idsc = sqlhand.clobToString(grc.get("items_desc")).split("~");
		isn = sqlhand.clobToString(grc.get("items_sn")).split("~");
		icol = kiboo.checkNullString(grc.get("items_coll")).split("~");
		
		f9 = "font-size:9px";

		for(i=0; i<itag.length; i++)
		{
			nrw = new org.zkoss.zul.Row();
			nrw.setParent(items_rows);

			gpMakeCheckbox(nrw,"","","");

			tmsn = "";
			try { tmsn = isn[i]; } catch (Exception e) {}

			tmds = "";
			try { tmds = idsc[i]; } catch (Exception e) {}

			if(!kst.equals("NEW"))
			{
				gpMakeLabel(nrw, "", itag[i], "");
				gpMakeLabel(nrw, "", tmsn, f9);
				klb = gpMakeLabel(nrw, "", tmds, f9);
				klb.setMultiline(true);
			}
			else
			{
				gpMakeTextbox(nrw,"",itag[i],"","99%");
				gpMakeTextbox(nrw,"",tmsn,f9,"99%");

				kbb = gpMakeTextbox(nrw,"",tmds,f9,"99%");
				kbb.setMultiline(true);
				kbb.setHeight("40px");
			}

			ckb = gpMakeCheckbox(nrw,"","","");
			if(!kst.equals("NEW"))
			{
				if(icol[i].equals("1")) ckb.setChecked(true);
			}
			else
			{
				ckb.setDisabled(true);
			}
		}
	}

	workarea.setVisible(true);
}

Object[] gdcols_headers =
{
	new listboxHeaderWidthObj("GCN",true,"40px"),
	new listboxHeaderWidthObj("Dated",true,"65px"),
	new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("Status",true,"60px"), // 3
	new listboxHeaderWidthObj("LC/CSV",true,"60px"),
	new listboxHeaderWidthObj("User",true,"60px"),
	new listboxHeaderWidthObj("Ack",true,""),
	new listboxHeaderWidthObj("Pickup",true,""),
	new listboxHeaderWidthObj("Transp",true,""),
	new listboxHeaderWidthObj("Comp",true,""),
	new listboxHeaderWidthObj("TempGRN",true,"70px"),
	new listboxHeaderWidthObj("SV.No",true,"60px"),
	new listboxHeaderWidthObj("ADT",true,"60px"),
};
adt_field = 12;
stt_field = 3;

class gdcolOnC implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		if(!glob_sel_gco.equals("") && !glob_sel_status.equals("COMPLETE") ) saveCollectItems(glob_sel_gco); // save previous GCO if any

		glob_sel_gcoli = event.getReference();
		glob_sel_gco = lbhand.getListcellItemLabel(glob_sel_gcoli,0);
		glob_sel_status = lbhand.getListcellItemLabel(glob_sel_gcoli,stt_field);
		glob_sel_adt = lbhand.getListcellItemLabel(glob_sel_gcoli,adt_field);
		showGCOMeta(glob_sel_gco);
	}
}
gdcliker = new gdcolOnC();

void showGoodsCollection()
{
	scht = kiboo.replaceSingleQuotes(searhtxt_tb.getValue()).trim();
	sdate = kiboo.getDateFromDatebox(startdate);
    edate = kiboo.getDateFromDatebox(enddate);

	Listbox newlb = lbhand.makeVWListbox_Width(collections_holder, gdcols_headers, "goodscol_lb", 5);

	scsql = "";
	if(!scht.equals("")) scsql = "and customer_name like '%" + scht + "%' ";

	sqlstm = "select origid,datecreated,username,customer_name,status,pickupdate,completedate,lc_id," +
	"ackdate,transporter,tempgrn,sv_no,qc_id " +
	"from rw_goodscollection where datecreated between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' " +
	scsql + "order by origid";

	screcs = sqlhand.gpSqlGetRows(sqlstm);
	if(screcs.size() == 0) return;

	newlb.setRows(22);
	newlb.setMold("paging");
	newlb.addEventListener("onSelect", gdcliker );
	ArrayList kabom = new ArrayList();

	String[] fl = { "origid", "datecreated", "customer_name", "status", "lc_id", "username", "ackdate",
	"pickupdate", "transporter", "completedate", "tempgrn", "sv_no", "qc_id" };

	for(d : screcs)
	{
		popuListitems_Data(kabom,fl,d);
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
}

void saveCollectItems(String iwhat)
{
	if(pitems_holder.getFellowIfAny("pickitems_grid") == null) return;
	cds = items_rows.getChildren().toArray();
	//if(cds.length < 1) return;
	icods = idesc = itik = isn = astgs = "";
	colcount = 0;
	refresh = false;
	todaydate =  kiboo.todayISODateTimeString();

	for(i=0; i<cds.length; i++)
	{
		c1 = cds[i].getChildren().toArray();
		icods += kiboo.replaceSingleQuotes( c1[1].getValue().replaceAll("~"," ") ) + "~";
		isn += kiboo.replaceSingleQuotes( c1[2].getValue().replaceAll("~"," ") ) + "~";
		idesc += kiboo.replaceSingleQuotes( c1[3].getValue().replaceAll("~"," ") ) + "~";
		itik += ( c1[4].isChecked() ) ? "1~" : "0~";

		if(c1[4].isChecked()) colcount++;

		// 28/10/2013: use to update rw_lc_equips
		if(!c1[1].getValue().equals(""))
			astgs += "'" + kiboo.replaceSingleQuotes( c1[1].getValue().trim() ) + "',";
	}

	try { icods = icods.substring(0,icods.length()-1); } catch (Exception e) {}
	try { idesc = idesc.substring(0,idesc.length()-1); } catch (Exception e) {}
	try { isn = isn.substring(0,isn.length()-1); } catch (Exception e) {}
	try { itik = itik.substring(0,itik.length()-1); } catch (Exception e) {}

	try { astgs = astgs.substring(0,astgs.length()-1); } catch (Exception e) {}

	jstat = "";

	// Check GCN/O status by counting items == colcount(ticked item)
	if(!glob_sel_status.equals("NEW") && colcount != 0)
	{
		totl = cds.length;
		if(colcount == totl)
		{
			jstat = ", status='COMPLETE', completedate='" + todaydate + "'";
			glob_sel_status = "COMPLETE";

			add_RWAuditLog(COLLECTION_PREFIX + iwhat, "", "COMPLETED collection", useraccessobj.username);

			// TODO send notif email when GCO totally completed and update rw_lc_equips/rw_lc_records
		}

		if(colcount < totl)
		{
			jstat = ", status='PARTIAL'";
			glob_sel_status = "PARTIAL";
		}
		refresh = true;
	}

	sqlstm = "";

	// Update rw_lc_equips.gcn_id to show linkage to this GCN
	lcid = kiboo.replaceSingleQuotes(lc_id.getValue().trim()); // lc_id def in formmak
	if(!lcid.equals(""))
	{
		sqlstm = "update rw_lc_equips set gcn_id=" + iwhat +
		" where lc_parent=(select origid from rw_lc_records where lc_id='" + lcid + "')" + 
		" and asset_tag in (" + astgs + ");";

		//alert(sqlstm);
	}

	sqlstm += "update rw_goodscollection set items_code='" + icods + "', items_desc='" + idesc + "', items_sn='" + isn + "', " + 
	"items_coll='" + itik + "'" + jstat + " where origid=" + iwhat;

	sqlhand.gpSqlExecuter(sqlstm);

	if(refresh) showGoodsCollection();
}

void removeCollectItems(Object irows)
{
	cds = irows.getChildren().toArray();
	if(cds.length < 1) return;
	for(i=0; i<cds.length; i++)
	{
		c1 = cds[i].getChildren().toArray();
		if(c1[0].isChecked()) cds[i].setParent(null);
	}
}

void genGCO_template(String igco)
{
	gcor = getGCO_rec(igco);
	if(gcro == null)
	{
		guihand.showMessageBox("DBERR: Cannot access GCO table!!");
		return;
	}

	startadder = 1;
	rowcount = 1 + startadder;

	templatefn = "rwimg/gcn_template_1.xls";
	inpfn = session.getWebApp().getRealPath(templatefn);
	InputStream inp = new FileInputStream(inpfn);
	HSSFWorkbook excelWB = new HSSFWorkbook(inp);
	evaluator = excelWB.getCreationHelper().createFormulaEvaluator();
	HSSFSheet sheet = excelWB.getSheetAt(0);
	//HSSFSheet sheet = excelWB.createSheet("THINGS");

	Font wfont = excelWB.createFont();
	wfont.setFontHeightInPoints((short)8);
	wfont.setFontName("Arial");

	try { daddr = kiboo.checkNullString(gcor.get("location")).replaceAll(",,",","); } catch (Exception e) {}

	dets1 =
	"CUSTOMER:\n" + kiboo.checkNullString(gcor.get("customer_name")) + "\n" +
	daddr +
	"\nContact person: " + kiboo.checkNullString(gcor.get("contact_person")) + 
	"\nTEL: " + kiboo.checkNullString(gcor.get("contact_tel")) +
	"\nEMAIL: " + kiboo.checkNullString(gcor.get("contact_email"));

	excelInsertString(sheet,0,0, dets1 );

	dets2 = COLLECTION_PREFIX + ": " + igco +
	"\nDated: " + dtf2.format(gcor.get("datecreated")) +
	"\nSO/LC/ROC No.: " + kiboo.checkNullString(gcor.get("lc_id")) +
	"\nSV No.: " + kiboo.checkNullString(gcor.get("sv_no")) +
	"\nPacking Materials: YES / NO" +
	"\nTransporter: " + kiboo.checkNullString(gcor.get("transporter")) + " " + kiboo.checkNullString(gcor.get("transp_ref")) +
	"\nPickup Date: " + ((gcor.get("pickupdate") == null) ? "" : dtf2.format(gcor.get("pickupdate"))) +
	"\nReq.By: " + gcor.get("username") +
	"\nNotes: " + kiboo.checkNullString(gcor.get("collection_notes"));

	excelInsertString(sheet,0,3, dets2 );

	String[] colhd = { "No.","Asset Tag","S/Number","Item description","Collected" };
	for(i=0;i<colhd.length;i++)
	{
		POI_CellSetAllBorders(excelWB,excelInsertString( sheet, 2, i, colhd[i] ),wfont,true,"");
	}

	itag = sqlhand.clobToString(gcor.get("items_code")).split("~");
	idsc = sqlhand.clobToString(gcor.get("items_desc")).split("~");
	isn = sqlhand.clobToString(gcor.get("items_sn")).split("~");

	if(itag.length > 0)
	{
		for(i=0; i<itag.length; i++)
		{
		POI_CellSetAllBorders(excelWB,excelInsertString( sheet, rowcount + startadder, 0, (i+1).toString() + "." ),wfont,true,"");

		tmtg = "";
		try { tmtg = itag[i]; } catch (Exception e) {}

		tmsn = "";
		try { tmsn = isn[i]; } catch (Exception e) {}

		tmds = "";
		try { tmds = idsc[i]; } catch (Exception e) {}

		POI_CellSetAllBorders(excelWB,excelInsertString( sheet, rowcount + startadder, 1, tmtg ),wfont,true,"");
		POI_CellSetAllBorders(excelWB,excelInsertString( sheet, rowcount + startadder, 2, tmsn ),wfont,false,"");
		POI_CellSetAllBorders(excelWB,excelInsertString( sheet, rowcount + startadder, 3, tmds ),wfont,false,"");
		POI_CellSetAllBorders(excelWB,excelInsertString( sheet, rowcount + startadder, 4, "" ),wfont,false,"");

		rowcount++;
		}
	}

	tfname = COLLECTION_PREFIX + igco + "_outp.xls";
	outfn = session.getWebApp().getRealPath("sharedocs/" + tfname );
	FileOutputStream fileOut = new FileOutputStream(outfn);
	excelWB.write(fileOut);
	fileOut.close();

	downloadFile(kasiexport,tfname,outfn);
}

