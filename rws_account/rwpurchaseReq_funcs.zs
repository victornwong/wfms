import org.victor.*;
import java.math.BigDecimal;
// RW purchase-requisition supporting funcs
// Written by : Victor Wong
// 05/03/2014: integrate FC6 temp-grn in grnPO_tracker.zul

void disableButts(boolean iwhat)
{
	newitem_b.setDisabled(iwhat);
	remitem_b.setDisabled(iwhat);
	calcitems_b.setDisabled(iwhat);
	saveitems_b.setDisabled(iwhat);
	updatepr_b.setDisabled(iwhat);
	asssupp_b.setDisabled(iwhat);
	getjobid_b.setDisabled(iwhat);
}

// Send noti-email for dis/approve PR
void prApprovalEmailNoti(String iprid, int itype)
{
	prc = getPR_rec(iprid);
	if(prc == null) return;
	reqr = sechand.getPortalUser_Rec_username( kiboo.checkNullString(prc.get("username")) ) ;
	if(reqr == null) return;
	if( kiboo.checkNullString(reqr.get("email")).equals("")) return;

	appst = "";
	switch(itype)
	{
		case 1:
			appst = "APPROVED";
			break;
		case 2:
			appst = "DISAPPROVED";
			break;
	}

	lnkc = PR_PREFIX + iprid;
	topeople = reqr.get("email") + ",satish@rentwise.com"; // HARDCODED: 1 email addr
	emailsubj = "RE: Your PR " + lnkc + " has been " + appst;
	emailmsg = "The PR you've submitted earlier has been " + appst;
	emailmsg += "\n\n(This is only a notification)";
	gmail_sendEmail("", GMAIL_username, GMAIL_password, GMAIL_username, topeople, emailsubj, emailmsg);
	//alert(prc + " :: " + reqr);
}

void checkPR_Approval(String iwhat)
{
	todaydate =  kiboo.todayISODateTimeString();
	appst = sqlstm = "";

	if(checkBPM_fullapproval(PR_PREFIX + iwhat)) // chk if full-approval
	{
		sqlstm = "update purchaserequisition set pr_status='APPROVED', approvedate='" + todaydate + "' where origid=" + iwhat;
		glob_sel_prstatus = "APPROVE";
		appst = "APPROVE";
		prApprovalEmailNoti(iwhat,1);
		disableButts(true);
	}
	else
	if(checkBPM_gotDisapproval(PR_PREFIX + iwhat)) // chk if any disapproval
	{
		sqlstm = "update purchaserequisition set pr_status='APPROVED', approvedate='" + todaydate + "' where origid=" + iwhat;
		glob_sel_prstatus = "DISAPPROVE";
		appst = "DISAPPROVE";
		prApprovalEmailNoti(iwhat,2);
	}

	if(!appst.equals(""))
		sqlstm = "update purchaserequisition set pr_status='" + appst + "', approvedate='" + todaydate + "' where origid=" + iwhat;

	if(!sqlstm.equals("")) sqlhand.gpSqlExecuter(sqlstm);
	showPRList();
}

void showPRMetadata(String iwhat)
{
	Object[] ob = { p_origid, p_datecreated, p_supplier_name, p_sup_contact, p_sup_tel, p_sup_fax, p_sup_email,
	p_sup_address, p_notes, p_sup_quote_ref, p_duedate, p_priority, p_job_id, p_creditterm, p_curcode,
	p_paydue_date, p_sup_etd };

	String[] fs = { "origid", "datecreated", "supplier_name", "sup_contact", "sup_tel", "sup_fax", "sup_email",
	"sup_address", "notes", "sup_quote_ref", "duedate", "priority", "job_id", "creditterm", "curcode",
	"paydue_date", "sup_etd" };

	prc = getPR_rec(iwhat);
	glob_pr_rec = prc; // 28/11/2013: store globally for later

	for(i=0; i<ob.length; i++)
	{
		if(ob[i] instanceof Textbox || ob[i] instanceof Label)
		{
			ds = "";
			kd = prc.get(fs[i]);
			if(kd instanceof Double || kd instanceof BigDecimal || kd instanceof Integer) ds = kd.toString();
			else
			if(kd instanceof Date) ds = dtf2.format( kd );
			else
			ds = kiboo.checkNullString( kd );

			ob[i].setValue(ds);
		}
		if(ob[i] instanceof Listbox) lbhand.matchListboxItems( ob[i], prc.get(fs[i]) );
		if(ob[i] instanceof Datebox) ob[i].setValue( prc.get(fs[i]) );
	}
/*
	p_origid.setValue(iwhat);
	p_datecreated.setValue( dtf2.format(prc.get("datecreated")) );
	p_supplier_name.setValue( prc.get("supplier_name") );
	p_sup_contact.setValue( kiboo.checkNullString(prc.get("sup_contact")) );
	p_sup_tel.setValue( kiboo.checkNullString(prc.get("sup_tel")) );
	p_sup_fax.setValue( kiboo.checkNullString(prc.get("sup_fax")) );
	p_sup_email.setValue( kiboo.checkNullString(prc.get("sup_email")) );
	p_sup_address.setValue( kiboo.checkNullString(prc.get("sup_address")) );
	p_notes.setValue( kiboo.checkNullString(prc.get("notes")) );
	p_sup_quote_ref.setValue( kiboo.checkNullString(prc.get("sup_quote_ref")) );
	p_duedate.setValue( prc.get("duedate") );
	lbhand.matchListboxItems(p_priority, prc.get("priority") );
	p_job_id.setValue( (prc.get("job_id") == null) ? "" : prc.get("job_id").toString() );
	p_creditterm.setValue( kiboo.checkNullString(prc.get("creditterm")) );
	p_curcode.setValue( kiboo.checkNullString(prc.get("curcode")) );
	p_paydue_date.setValue(prc.get("paydue_date"));
	if(prc.get("sup_etd") != null) p_sup_etd.setValue( prc.get("sup_etd") );
*/
	fillDocumentsList(documents_holder,PR_PREFIX,iwhat);
	showJobNotes(JN_linkcode(),jobnotes_holder,"jobnotes_lb"); // customize accordingly here..

	if(!prc.get("pr_status").equals("CANCEL"))
		showApprovalThing(PR_PREFIX + iwhat, "PR", approvers_box );
	else
		if(approvers_box.getFellowIfAny("app_grid") != null) app_grid.setParent(null); // clear the approver-box

	// show PR items,prices,qty
	if(pritems_holder.getFellowIfAny("pritems_grid") != null) pritems_grid.setParent(null);
	checkMakeItemsGrid();

	ktg = sqlhand.clobToString(prc.get("pr_items"));
	if(!ktg.equals(""))
	{
		itms = sqlhand.clobToString(prc.get("pr_items")).split("~");
		iqty = sqlhand.clobToString(prc.get("pr_qty")).split("~");
		iupr = sqlhand.clobToString(prc.get("pr_unitprice")).split("~");
		ks = "font-weight:bold;";

		for(i=0; i<itms.length; i++)
		{
			irow = new org.zkoss.zul.Row();
			irow.setParent(pritems_rows);

			gpMakeCheckbox(irow,"", "","");
			itm = "";
			try { itm = itms[i]; } catch (Exception e) {}
			desb = gpMakeTextbox(irow,"",itm,ks,"99%");
			desb.setMultiline(true);
			desb.setHeight("70px");

			qty = "";
			try { qty = iqty[i]; } catch (Exception e) {}
			gpMakeTextbox(irow,"",qty,ks,"99%"); // qty
			
			unp = "";
			try { unp = iupr[i]; } catch (Exception e) {}
			gpMakeTextbox(irow,"",unp,ks,"99%"); // unit price

			gpMakeLabel(irow,"","",ks); // sub-total
		}
	}

	total_lbl.setValue("");
	calcPRItems(pritems_rows); // do pr-items calc

	prst = ( prc.get("pr_status").equals("DRAFT") ) ? false : true;
	disableButts(prst);

	BPM_toggleButts( true, approvers_box);

	if(sechand.allowedUser(useraccessobj.username,"PR_APPROVERS"))
		BPM_toggleButts( (prc.get("pr_status").equals("SUBMIT")) ? false : true, approvers_box);

	workarea.setVisible(true);
	bpm_area.setVisible(true);

}

Object[] prlb_hds =
{
	new listboxHeaderWidthObj("PR#",true,"40px"),
	new listboxHeaderWidthObj("Dated",true,"65px"),
	new listboxHeaderWidthObj("Supplier",true,""),
	new listboxHeaderWidthObj("User",true,"60px"),
	new listboxHeaderWidthObj("Priority",true,"60px"),
	new listboxHeaderWidthObj("Notify",true,"60px"), // 5
	new listboxHeaderWidthObj("Status",true,"60px"), // 6
	new listboxHeaderWidthObj("Job-ID",true,"60px"),
	new listboxHeaderWidthObj("Due",true,"60px"),
	new listboxHeaderWidthObj("Appr",true,"60px"),
	new listboxHeaderWidthObj("Sup.ETD",true,"65px"),
	new listboxHeaderWidthObj("Sup.Del",true,"65px"),
	new listboxHeaderWidthObj("D.Stat",true,"70px"),
	new listboxHeaderWidthObj("T.GRN",true,"40px"),
	new listboxHeaderWidthObj("Ver",true,"30px"), // 14
};

p_ver = 14;
p_stt = 6;
p_cnm = 2;

class prlbcjlick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		glob_sel_prid = lbhand.getListcellItemLabel(isel,0);
		glob_sel_prstatus = lbhand.getListcellItemLabel(isel,p_stt);
		glob_sel_prversion = lbhand.getListcellItemLabel(isel,p_ver);
		global_selected_customer = lbhand.getListcellItemLabel(isel,p_cnm);
		showPRMetadata(glob_sel_prid);
	}
}

prlbclicker = new prlbcjlick();

void showPRList()
{
	scht = kiboo.replaceSingleQuotes(searhtxt_tb.getValue().trim()); // search by customer-name and so on
	sprn = kiboo.replaceSingleQuotes(searchprno_tb.getValue().trim()); // search by PR no.
	sdate = kiboo.getDateFromDatebox(startdate);
    edate = kiboo.getDateFromDatebox(enddate);

	Listbox newlb = lbhand.makeVWListbox_Width(prlist_holder, prlb_hds, "prs_lb", 22);
    if(!sprn.equals("")) scht = "";
	scsql = "";
	if(!scht.equals("")) scsql = "and suppliername like '%" + scht + "%' ";
	whdts = "where datecreated between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' ";

	sqlstm = "select origid,datecreated,supplier_name,username,priority,pr_status,duedate,approvedate," + 
	"sup_etd,sup_actual_deldate,job_id,version,notify_pr,del_status,temp_grn from purchaserequisition ";

	if(!scht.equals("")) sqlstm += whdts + "and supplier_name like '%" + scht + "%' ";
	else
	if(!sprn.equals("")) { sqlstm += "where origid=" + sprn; searchprno_tb.setValue(""); } // clear by-PR-box
	else
	sqlstm += whdts;
	//debugbox.setValue(sqlstm);

	screcs = sqlhand.gpSqlGetRows(sqlstm);
	if(screcs.size() == 0) return;
	newlb.setMold("paging");
	newlb.addEventListener("onSelect", prlbclicker );
	ArrayList kabom = new ArrayList();
	for(dpi : screcs)
	{
		kabom.add( dpi.get("origid").toString() );
		kabom.add( dtf2.format(dpi.get("datecreated")) );
		kabom.add( kiboo.checkNullString(dpi.get("supplier_name")) );
		kabom.add( kiboo.checkNullString(dpi.get("username")) );
		prit = kiboo.checkNullString(dpi.get("priority"));
		kabom.add(prit);

		kabom.add( kiboo.checkNullDate(dpi.get("notify_pr"),"") );

		stt = kiboo.checkNullString(dpi.get("pr_status"));
		kabom.add(stt);
		kabom.add( (dpi.get("job_id") == null) ? "" : dpi.get("job_id").toString() );
		kabom.add( dtf2.format(dpi.get("duedate")) );

		appd = kiboo.checkNullDate(dpi.get("approvedate"),"");
		kabom.add(appd);
		spetd = kiboo.checkNullDate(dpi.get("sup_etd"),"");
		kabom.add(spetd);
		supdeld = kiboo.checkNullDate(dpi.get("sup_actual_deldate"),"");
		kabom.add(supdeld);

		kabom.add( kiboo.checkNullString(dpi.get("del_status")) );
		kabom.add( kiboo.checkNullString(dpi.get("temp_grn")) );

		kabom.add( (dpi.get("version") == null) ? "" : dpi.get("version").toString() );

		styl = "";
		if(kiboo.todayISODateString().equals(spetd) && supdeld.equals(""))
			styl = "background:#e58512;font-size:9px";

		if(prit.equals("URGENT") || prit.equals("CRITICAL") )
			styl = "font-weight:bold;color:#ffffff;background:#cc0000;font-size:9px";

		if(stt.equals("APPROVE"))
		{
			styl = "font-weight:bold;background:#73d216;font-size:9px";
			if( prit.equals("URGENT") || prit.equals("CRITICAL") )
				styl += ";background:#ef2929;color:#ffffff";
		}

		if(stt.equals("DISAPPROVE"))
			styl = "font-weight:bold;background:#ad7fa8;font-size:9px";

		strarray = kiboo.convertArrayListToStringArray(kabom);
		lbhand.insertListItems(newlb,strarray,"false",styl);
		kabom.clear();
	}
}

void savePRItems(String iwhat)
{
	if(pritems_holder.getFellowIfAny("pritems_grid") == null) return;
	cds = pritems_rows.getChildren().toArray();
	//if(cds.length < 1) return;
	itms = iqty = iuprice = "";
	todaydate =  kiboo.todayISODateTimeString();

	for(i=0; i<cds.length; i++)
	{
		c1 = cds[i].getChildren().toArray();
		itms += kiboo.replaceSingleQuotes( c1[1].getValue().replaceAll("~"," ") ) + "~";
		iqty += kiboo.replaceSingleQuotes( c1[2].getValue().replaceAll("~"," ") ) + "~";
		iuprice += kiboo.replaceSingleQuotes( c1[3].getValue().replaceAll("~"," ") ) + "~";
	}

	try { itms = itms.substring(0,itms.length()-1); } catch (Exception e) {}
	try { iqty = iqty.substring(0,iqty.length()-1); } catch (Exception e) {}
	try { iuprice = iuprice.substring(0,iuprice.length()-1); } catch (Exception e) {}

	sqlstm = "update purchaserequisition set pr_items='" + itms + "', pr_qty='" + iqty + "', pr_unitprice='" + iuprice + "' " +
	"where origid=" + iwhat;

	sqlhand.gpSqlExecuter(sqlstm);
}

void checkMakeItemsGrid()
{
	String[] colws = { "15px","350px"           ,"60px","60px",   "80px" };
	String[] colls = { "" ,"Item description","Qty" ,"U.Price","Sub.Total" };

	if(pritems_holder.getFellowIfAny("pritems_grid") == null) // make new grid if none
	{
		igrd = new Grid();
		igrd.setId("pritems_grid");
		//igrd.setWidth("800px");

		icols = new org.zkoss.zul.Columns();
		for(i=0;i<colws.length;i++)
		{
			ico0 = new org.zkoss.zul.Column();
			ico0.setWidth(colws[i]);
			ico0.setLabel(colls[i]);
			ico0.setAlign("center");
			ico0.setStyle("background:#97b83a");
			ico0.setParent(icols);
		}
		icols.setParent(igrd);
		irows = new org.zkoss.zul.Rows();
		irows.setId("pritems_rows");
		irows.setParent(igrd);
		igrd.setParent(pritems_holder);
	}
}

// Calculate sub-total and populate column
void calcPRItems(Object irows)
{
	cds = irows.getChildren().toArray();
	if(cds.length < 1) return;
	gtotal = 0.0;
	for(i=0; i<cds.length; i++)
	{
		c1 = cds[i].getChildren().toArray();
		qty = c1[2].getValue();
		upr = c1[3].getValue();
		subt = 0.0;
		try { subt = Integer.parseInt(qty) * Float.parseFloat(upr); } catch (Exception e) {}
		gtotal += subt;
		c1[4].setValue(nf.format(subt));
	}
	total_lbl.setValue(nf.format(gtotal));
}

void removePRItems(Object irows)
{
	cds = irows.getChildren().toArray();
	if(cds.length < 1) return;
	for(i=0; i<cds.length; i++)
	{
		c1 = cds[i].getChildren().toArray();
		if(c1[0].isChecked()) cds[i].setParent(null); // remove only CHECKED items
	}
}

void sendNoti_newPR(String iwhat,String iwho)
{
	lnkc = PR_PREFIX + iwhat;
	topeople = "satish@rentwise.com,sangeetha@rentwise.com"; // TODO HARDCODED 29/11/2013
	//topeople = "victor@rentwise.com";
	emailsubj = "RE: New " + lnkc + " requested by " + iwho;
	emailmsg = "A new PR has been created. Pending procurement-division action.";
	gmail_sendEmail("", GMAIL_username, GMAIL_password, GMAIL_username, topeople, emailsubj, emailmsg);
	guihand.showMessageBox("Email-notification sent to procurement-division");
}

void sendPR_approver_email(String iwhat)
{
	lnkc = PR_PREFIX + iwhat;
	topeople = getFieldsCommaString("PR_APPROVERS",1);
	emailsubj = "RE: New " + lnkc + " submitted [" + glob_pr_rec.get("priority") + "]";
	emailmsg = "A new PR has been submitted. Pending approval, your action is required.";
	gmail_sendEmail("", GMAIL_username, GMAIL_password, GMAIL_username, topeople, emailsubj, emailmsg);
}

