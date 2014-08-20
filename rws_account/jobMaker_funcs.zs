import org.victor.*;
// Rentwise Jobmaker module funcs

/*
SimpleDateFormat dtf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
SimpleDateFormat dtf2 = new SimpleDateFormat("yyyy-MM-dd");
DecimalFormat nf2 = new DecimalFormat("#0.00");
DecimalFormat nf3 = new DecimalFormat("###,##0.00");
*/

glob_icomponents_counter = 1; // use globally to set items components ID

void showRentableItems(Div iholder, String lbid, String istockcat, String ipname)
{
Object[] stklist_headers = {
	new listboxHeaderWidthObj("Models",true,""),
	new listboxHeaderWidthObj("Avail",true,"60px"), };
	Listbox newlb = lbhand.makeVWListbox_Width(iholder, stklist_headers, lbid, 3);

	whrstr = "item='DT' or item='DR'";
	if(istockcat.equals("NB") || istockcat.equals("MT")) whrstr = "item='" +  istockcat + "'";
	if(istockcat.equals("") && !ipname.equals("")) whrstr = "name like '%" + ipname + "%'";

	sqlstm = "select distinct name, sum(qty) as unitc from partsall_1 " +
	"where " + whrstr + " group by name,qty order by name;";

	r = sqlhand.rws_gpSqlGetRows(sqlstm);
	if(r.size() == 0) return;
	newlb.setRows(10);
	newlb.setMold("paging");
	//newlb.addEventListener("onSelect", new jobsClick());
	ArrayList kabom = new ArrayList();
	for(d : r)
	{
		kabom.add( kiboo.checkNullString(d.get("name")) );
		kabom.add( nf0.format(d.get("unitc")) );
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"true","");
		kabom.clear();
	}
}

// might be usable for other mods -- show in-stock DT and NB models
void showRentableItems2(Div iholder, String lbid, String istockcat)
{
Object[] stklist_headers =
{
	new listboxHeaderWidthObj("Models",true,""),
	new listboxHeaderWidthObj("Avail",true,"60px"),
};
	Listbox newlb = lbhand.makeVWListbox_Width(iholder, stklist_headers, lbid, 3);

	sqlstm = "select distinct smd.brandname, smd.description, " +
	"(select count(id) from stockmasterdetails where " +
	"description = smd.description and bom_id is null and rma_id is null) as unitc " +
	"from stockmasterdetails smd " +
	"where smd.stock_cat='" + istockcat + "' and smd.brandname is not null";

	screcs = sqlhand.gpSqlGetRows(sqlstm);
	if(screcs.size() == 0) return;
	newlb.setRows(10);
	newlb.setMold("paging");
	//newlb.addEventListener("onSelect", new jobsClick());
	ArrayList kabom = new ArrayList();
	for(dpi : screcs)
	{
		kabom.add( kiboo.checkNullString(dpi.get("brandname")) + ": " + kiboo.checkNullString(dpi.get("description")) );
		kabom.add( dpi.get("unitc").toString() );
		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"true","");
		kabom.clear();
	}
}

void showJobMetadata(String iwhat)
{
	j_origid.setValue(iwhat);
	jrec = getRWJob_rec(iwhat);
	if(jrec == null) { guihand.showMessageBox("ERR: Cannot access jobs database.."); return; }

	String[] flds = { "username", "customer_name", "jobtype", "quote_no_old", "rwroc", "cust_ref", "prepayment",
	"contract_start", "priority", "contact", "contact_tel", "contact_email", "deliver_address",
	"do_notes", "order_type", "debit_note", "whoscode", "eta", "etd" };

	Object[] uiob = { j_username, customername, j_jobtype, j_quote_no_old, j_rwroc, j_cust_ref, j_prepayment,
	j_contract_start, j_priority, j_contact, j_contact_tel, j_contact_email, j_deliver_address,
	j_do_notes, j_order_type, j_debit_note, j_whoscode, j_eta, j_etd };

	populateUI_Data(uiob, flds, jrec);

	fc6n = (jrec.get("fc6_custid") == null) ? "" : jrec.get("fc6_custid").toString();
	j_fc6_custid.setValue(fc6n); // hidden fc6 cust-id

	showJobItems(jrec);
	fillDocumentsList(documents_holder,JOBS_PREFIX,iwhat);

	showApprovalThing(JOBS_PREFIX + iwhat, jrec.get("jobtype"), approvers_box );

	// Update bpm-approval things
	appf = checkBPM_fullapproval(JOBS_PREFIX + iwhat);
	sqlstm = "update rw_jobs set approve=" + ( (appf) ? "1" : "0" ) + " where origid=" + iwhat;
	sqlhand.gpSqlExecuter(sqlstm);
	if(glob_sel_joblistitem != null) // update list-item
	{
		lbhand.setListcellItemLabel(glob_sel_joblistitem,10,(appf) ? "YES" : "NO"); // HARDCODED colm posi = 9
	}

	BPM_toggleButts( (glob_sel_status.equals("SUBMIT")) ? false : true, approvers_box);

	if( sechand.allowedUser(useraccessobj.username,"CC_APPROVER_USER") || sechand.allowedUser(useraccessobj.username,"SALES_APPROVER_USER") )
		BPM_toggleButts( (glob_sel_status.equals("SUBMIT")) ? false : true, approvers_box);

	showJobNotes(JN_linkcode(),jobnotes_holder,"jobnotes_lb"); // customize accordingly here..
	jobnotes_div.setVisible(true);

	workarea.setVisible(true);
}

Object[] jobs_headers =
{
	new listboxHeaderWidthObj("###",true,"50px"),
	new listboxHeaderWidthObj("fc6",false,""),
	new listboxHeaderWidthObj("Dated",true,"60px"),
	new listboxHeaderWidthObj("ETA",true,"60px"),
	new listboxHeaderWidthObj("ETD",true,"60px"),
	new listboxHeaderWidthObj("User",true,"60px"), // 5
	new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("Type",true,"50px"),
	new listboxHeaderWidthObj("ROC.No",true,"60px"),
	new listboxHeaderWidthObj("Stat",true,"60px"), // 9
	new listboxHeaderWidthObj("App",true,"30px"),
	new listboxHeaderWidthObj("BOM",true,"40px"), // 11
	new listboxHeaderWidthObj("BOM DO",true,"60px"),
	new listboxHeaderWidthObj("P.By",true,"60px"), // 13
	new listboxHeaderWidthObj("P.Date",true,"60px"),
	new listboxHeaderWidthObj("P.Lst",true,"60px"), // 15
	new listboxHeaderWidthObj("PPL DO",true,"60px"),
	new listboxHeaderWidthObj("C.By",true,"60px"), // 17
	new listboxHeaderWidthObj("C.Date",true,"60px"),
	new listboxHeaderWidthObj("PR",true,"60px"), // 19
	new listboxHeaderWidthObj("WH/OS",true,"60px"),
	new listboxHeaderWidthObj("Inv",true,"60px"), // 21
};

glob_sel_joblistitem = null;
z_jobid = 0;
z_fc6 = 1;
z_cstn = 6;
z_jbty = 7;
z_stat = 9;
z_pck = 13;
z_cmp = 17;
z_bid = 11;
z_pls = 15;

class jobsClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getReference();
		glob_sel_joblistitem = isel; // later use
		glob_sel_job = lbhand.getListcellItemLabel(isel,z_jobid);
		glob_sel_fc6 = lbhand.getListcellItemLabel(isel,z_fc6);
		glob_sel_custname = lbhand.getListcellItemLabel(isel,z_cstn);
		glob_sel_jobtype = lbhand.getListcellItemLabel(isel,z_jbty);
		glob_sel_status = lbhand.getListcellItemLabel(isel,z_stat);
		glob_sel_pickup = lbhand.getListcellItemLabel(isel,z_pck);
		glob_sel_complete = lbhand.getListcellItemLabel(isel,z_cmp);
		glob_sel_bomid = lbhand.getListcellItemLabel(isel,z_bid);
		glob_sel_picklist = lbhand.getListcellItemLabel(isel,z_pls);

		toggleButts("all", (glob_sel_status.equals("NEW")) ? false : true );
		if(glob_sel_status.equals("SUBMIT")) toggleButts("pickjob_b",false);

		showJobMetadata(glob_sel_job);
	}
}
jboclicko = new jobsClick();

void showJobs()
{
	scht = kiboo.replaceSingleQuotes(searhtxt_tb.getValue().trim());
	sdate = kiboo.getDateFromDatebox(startdate);
	edate = kiboo.getDateFromDatebox(enddate);
	Listbox newlb = lbhand.makeVWListbox_Width(jobs_holder, jobs_headers, "jobs_lb", 5);

	sqlstm = 
	"select jbs.origid, jbs.datecreated, jbs.username, jbs.jobtype, jbs.fc6_custid, jbs.customer_name, jbs.status," +
	"jbs.approve, jbs.pickup_by, jbs.pickup_date, jbs.complete_date, jbs.complete_by, jbs.eta, jbs.etd, jbs.whoscode, " +
	"jbs.rwroc " +
	//"(select origid from stockrentalitems where job_id = jbs.origid) as bomid " +
	"from rw_jobs jbs " +
	"where jbs.datecreated between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' ";

	if(!scht.equals("")) sqlstm += "and (jbs.customer_name like '%" + scht + "%' or jbs.rwroc like '%" + scht + "%') ";

	sqlstm += "order by jbs.origid ";

	//guihand.showMessageBox(sqlstm); return;

	screcs = sqlhand.gpSqlGetRows(sqlstm);
	if(screcs.size() == 0) return;
	newlb.setRows(15);
	newlb.setMold("paging");
	newlb.addEventListener("onSelect", jboclicko);
	ArrayList kabom = new ArrayList();
	for(dpi : screcs)
	{
		jbid = dpi.get("origid").toString();
		kabom.add(jbid);
		kabom.add( (dpi.get("fc6_custid") == null) ? "" : dpi.get("fc6_custid").toString() );
		kabom.add( dtf.format(dpi.get("datecreated")) );
		kabom.add( dtf2.format(dpi.get("eta")) );
		kabom.add( dtf2.format(dpi.get("etd")) );
		kabom.add(kiboo.checkNullString(dpi.get("username")));
		kabom.add(kiboo.checkNullString(dpi.get("customer_name")));
		kabom.add(kiboo.checkNullString(dpi.get("jobtype")));
		kabom.add(kiboo.checkNullString(dpi.get("rwroc")));
		kabom.add(kiboo.checkNullString(dpi.get("status")));

		apr = (dpi.get("approve") == null) ? "NO" : ( (dpi.get("approve")) ? "YES" : "NO" ) ;
		kabom.add(apr);

		tboms = getLinkingJobID_others(BOM_JOBID,jbid).trim();
		kabom.add(tboms);
		kabom.add( getDOLinkToJob(2,tboms) );

		kabom.add(kiboo.checkNullString(dpi.get("pickup_by")));
		kabom.add( kiboo.checkNullDate(dpi.get("pickup_date"),"") );

		tppls = getLinkingJobID_others(PICKLIST_JOBID,jbid).trim();
		kabom.add(tppls);
		kabom.add( getDOLinkToJob(1,tppls) );

		kabom.add(kiboo.checkNullString(dpi.get("complete_by")));
		kabom.add( (dpi.get("complete_date") == null) ? "" : dtf.format(dpi.get("complete_date")) );
		kabom.add( getDOLinkToJob(3,jbid) );
		kabom.add(kiboo.checkNullString(dpi.get("whoscode")));

		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	jobs_holder.setVisible(true);
}

void checkMakeItemsGrid()
{
	String[] colws = { "50px","350px",           "60px" ,"60px","60px",    "60px",     "80px",   "80px" };
	String[] colls = { "No." ,"Item description","Color","Qty" ,"R.Period","R.PerUnit","ROC Monthly","Sub.Total" };

	if(items_holder.getFellowIfAny("items_grid") == null) // make new grid if none
	{
		igrd = new Grid();
		igrd.setId("items_grid");
		igrd.setWidth("800px");

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
		irows.setId("items_rows");
		irows.setParent(igrd);
		igrd.setParent(items_holder);
	}
}

void showJobItems(Object tjrc)
{
	if(items_holder.getFellowIfAny("items_grid") != null) items_grid.setParent(null);
	saved_label.setVisible(false);
	grandtotalbox.setVisible(false);
	
	glob_icomponents_counter = 1; // reset for new grid

	if(tjrc.get("items") == null) return; // nothing to show

	checkMakeItemsGrid();
	items = tjrc.get("items").split("::");
	qtys = tjrc.get("qtys").split("::");
	colors = tjrc.get("colors").split("::");
	rental_periods = tjrc.get("rental_periods").split("::");
	rent_perunits = tjrc.get("rent_perunits").split("::");

	glob_icomponents_counter = 1;
	
	kk = "font-weight:bold;";

	for(i=0;i<items.length;i++)
	{
		cmid = glob_icomponents_counter.toString();

		irow = gridhand.gridMakeRow("IRW" + cmid ,"","",items_rows);
		gpMakeCheckbox(irow,"CBX" + cmid, cmid + ".", kk + "font-size:14px");

		soms = "";
		try { soms = items[i]; } catch (Exception e) {}

		desb = gpMakeTextbox(irow,"IDE" + glob_icomponents_counter.toString(),soms,"font-size:9px;font-weight:bold;","99%");
		desb.setMultiline(true);
		desb.setHeight("70px");
		desb.setDroppable("true");
		desb.addEventListener("onDrop",new dropModelName());

		soms = "";
		try { soms = colors[i]; } catch (Exception e) {}
		gpMakeTextbox(irow,"ICL" + cmid ,soms, kk,"99%"); // color

		soms = "";
		try { soms = qtys[i]; } catch (Exception e) {}
		gpMakeTextbox(irow,"IQT" + cmid,soms,kk,"99%"); // qty

		soms = "";
		try { soms = rental_periods[i]; } catch (Exception e) {}
		gpMakeTextbox(irow,"IRP" + cmid,soms,kk,"99%"); // rental-period

		soms = "";
		try { soms = rent_perunits[i]; } catch (Exception e) {}
		gpMakeTextbox(irow,"IRU" + cmid,soms,kk,"99%"); // rental per unit

		gpMakeLabel(irow,"MON" + cmid,"",kk); // per month total
		gpMakeLabel(irow,"RTO" + cmid,"",kk); // rental all total

		glob_icomponents_counter++;
	}

	jobItems(ji_calc_b); // Do items total/rental calcs
}

// drag-drop mode-name into item-description
class dropModelName implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		Component dragged = event.dragged;
		kk = event.getTarget();
		kk.setValue(kk.getValue() + " " + dragged.getLabel());
	}
}
dropMname = new dropModelName();


