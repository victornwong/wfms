import java.util.*;
import java.text.*;
import java.lang.Float;
import java.awt.Color;
import java.io.FileOutputStream;
import javax.mail.*;
import javax.mail.internet.*;
import javax.activation.*;
import groovy.sql.Sql;
import org.zkoss.zk.ui.*;
import org.zkoss.zk.zutl.*;

import org.victor.*;
// customer support module supp funcs

// Actual email SOF to customer. uses funcs in emailfuncs.zs
// TODO get Faiz to create a new
void email_SOF(String iwho, String imsgb)
{
	genServiceOrderFormPdf(glob_selected_ticket); // gen SOF PDF in tmp
	fncm = "SERVICEORDER_" + glob_selected_ticket + ".pdf";
	String[] fnms = { 
		session.getWebApp().getRealPath(TEMPFILEFOLDER + fncm)
	};

	subj = TICKETSV_PREFIX + glob_selected_ticket + " : Service Order Form";
	tmsgb = "Please find the attached Service-Order-Form in this email. Do save it for further reference.\n\n" + imsgb;

	MS_sendEmailWithAttachment(SYS_SMTPSERVER,SYS_EMAILUSER,SYS_EMAILPWD,SYS_EMAIL,iwho,subj,tmsgb,fnms);
}

// Disable/Enable some buttons
void disableButts(boolean iwhat)
{
	selcustomer_b.setDisabled(iwhat);
	updatet_b.setDisabled(iwhat); // update ticket details
}

// Send email notif by lookup-tbl
void sendServiceChargeable_noti(String itick)
{
	// chk if anything entered..
	fnditm = 0;
	for(i=1;i<5;i++)
	{
		itmo = chargeitems_grid.getFellowIfAny("c_item_" + i.toString());
		itmstr = kiboo.replaceSingleQuotes(itmo.getValue().trim());
		if(!itmstr.equals("")) fnditm++;
	}

	if(fnditm == 0) // nothing entered.. don't send request email
	{
		guihand.showMessageBox("Nothing to request a quote for..");
		return;
	}

	topeople = luhand.getLookups_ConvertToStr("SERVICE_REQ_QUOTE_EMAILS",2,",");
	tcks = TICKETSV_PREFIX + itick;
	msgbody = tcks + " contains chargeable items. Please fulfill the service-order-form chargeable items prices ASAP.";
	if(simpleSendemail_MSEX(SYS_SMTPSERVER,SYS_EMAILUSER,SYS_EMAILPWD,
		SYS_EMAIL,topeople,"[" + tcks + "] ACTION REQUIRED: Customer service chargeable items",msgbody) )
		guihand.showMessageBox("Request-quote email sent..");
}

void showTicketMetadata(String iwhat)
{
	tkr = getHelpTicket_rec(iwhat);
	if(tkr == null) { guihand.showMessageBox("ERR: Cannot access database.."); return; }

	t_origid.setValue(TICKETSV_PREFIX + iwhat);
	global_selected_customerid = kiboo.checkNullString(tkr.get("fc6_custid"));
	global_selected_customername = kiboo.checkNullString(tkr.get("cust_name"));
	customername.setValue(kiboo.checkNullString(tkr.get("cust_name")));

	// chg ticket-metadata header bkgrnd color by priority
	kpri = tkr.get("priority");
	thds = NORMAL_BACKGROUND;
	if(kpri.equals("URGENT")) thds = URGENT_BACKGROUND;
	if(kpri.equals("CRITICAL")) thds = CRITICAL_BACKGROUND;
	tickmeta_hd1.setStyle(thds);
	tickmeta_hd2.setStyle(thds);
	//hd_priority.setValue(kpri);
	//hd_tstatus.setValue(tkr.get("tstatus"));
	txtcolor = "color:#f57900";
	if(!thds.equals(NORMAL_BACKGROUND)) txtcolor = "color:#111111";

	changeChildrenStyle(tickmeta_hd1.getChildren(),txtcolor);
	changeChildrenStyle(tickmeta_hd2.getChildren(),txtcolor);

	String[] fl = { "cust_caller", "cust_caller_phone", "cust_caller_des", "cust_caller_email", "cust_location",
	"asset_tag", "serial_no", "product_name", "assign_to", "problem", "action", "resolved_by", "resolve_type",
	"resolution", "os_id", "os_user", "os_pickup", "os_resolvedate", "os_resolution", "priority", "priority", "tstatus" };

	Object[] ob = { t_cust_caller, t_cust_caller_phone, t_cust_caller_des, t_cust_caller_email, t_cust_location,
	t_asset_tag, t_serial_no, t_product_name, t_assign_to, t_problem, t_action, t_resolved_by, t_resolve_type,
	t_resolution, t_os_id, t_os_user, t_os_pickup, t_os_resolve, t_os_resolution, t_priority, hd_priority, hd_tstatus };

	populateUI_Data(ob,fl,tkr);

	//t_resolved_on
	//t_resolve_type.setValue( kiboo.checkNullString(tkr.get("resolve_type")) );

	fillDocumentsList(documents_holder,TICKETSV_PREFIX,iwhat);
	showEquipmentActivity(iwhat);
	showSystemAudit(ticksactivs_holder, TICKETSV_PREFIX + iwhat, "");

	Object itms,iup,iqty;

	// show charge-items
	if(tkr.get("charge_items") != null)
	{
		irc = tkr.get("charge_items");
		itms = irc.split("::");
		irc = tkr.get("charge_unitprice");
		iup = irc.split("::");
		irc = tkr.get("charge_qty");
		iqty = irc.split("::");
	}

	for(i=1;i<5;i++)
	{
		cnt = i.toString();
		itmo = chargeitems_grid.getFellowIfAny("c_item_" + cnt);
		itmo.setValue("");
		if(itms instanceof String[])
		{
			try { itmo.setValue(itms[i-1]); } catch (Exception e) {}
		}

		upo = chargeitems_grid.getFellowIfAny("c_unitprice_" + cnt);
		upo.setValue("");
		if(iup instanceof String[])
		{
			try { upo.setValue(iup[i-1]); }	catch (Exception e) {}
		}

		qtyo = chargeitems_grid.getFellowIfAny("c_qty_" + cnt);
		qtyo.setValue("");
		if(iqty instanceof String[])
		{
			try { qtyo.setValue(iqty[i-1]); } catch (Exception e) {}
		}
	}

	chargeItems(recalc_b); // do recalc on charge-items if any

	// enable or disable charge-item unit price input
	untps = sechand.allowedUser(useraccessobj.username,"SERVICE_QUOTE_USERS") ? false : true;
	for(i=1;i<5;i++)
	{
		upi = chargeitems_grid.getFellowIfAny("c_unitprice_" + i.toString());
		upi.setDisabled(untps);
	}

	workarea.setVisible(true);
	workbutts.setVisible(true);
}

// show ticket's equipment (asset) activity - how link to which RMA for now
void showEquipmentActivity(String iwhat)
{
	// remove prev grid
	if(equip_rma_holder.getFellowIfAny("rma_grid") != null) rma_grid.setParent(null);

	sqlstm = "select rma.origid as rmaid, rma.datecreated, rma.rstatus, rma.pickupdate, rma.pickupby, rma.completed " + 
	"from rw_localrma rma " +
	"left join rw_localrma_items rmai on rmai.parent_id = rma.origid where rmai.helpticket_id = " + iwhat;

	rmr = sqlhand.gpSqlFirstRow(sqlstm);
	if(rmr == null) return;

	Grid rgrid = new Grid();
	rgrid.setId("rma_grid");
	mrows = gridhand.gridMakeRows("","",rgrid);
	prow = gridhand.gridMakeRow("","","",mrows);
	gridhand.makeLabelToParent("RMA#", "font-size:9px",prow);
	gridhand.makeLabelToParent(rmr.get("rmaid").toString(), "font-size:9px",prow);
	gridhand.makeLabelToParent("Dated", "font-size:9px",prow);
	gridhand.makeLabelToParent(rmr.get("datecreated").toString().substring(0,10), "font-size:9px",prow);
	gridhand.makeLabelToParent("Pickup", "font-size:9px",prow);
	gridhand.makeLabelToParent(kiboo.checkNullDate(rmr.get("pickupdate"),""), "font-size:9px",prow);
	gridhand.makeLabelToParent("Pick.By", "font-size:9px",prow);
	gridhand.makeLabelToParent(kiboo.checkNullString(rmr.get("pickupby")), "font-size:9px",prow);
	gridhand.makeLabelToParent("Complete", "font-size:9px",prow);
	gridhand.makeLabelToParent(kiboo.checkNullDate(rmr.get("completed"),""), "font-size:9px",prow);

	rgrid.setParent(equip_rma_holder);
	vequiprma_b.setVisible(true);

	//kstr = "RMA# " +  + " Date: " +  + " Status: "
}

Object[] tkslb_headers =
{
	new listboxHeaderWidthObj("CSV#",true,"40px"),
	new listboxHeaderWidthObj("Dated",true,"65px"),
	new listboxHeaderWidthObj("Customer",true,""),
	new listboxHeaderWidthObj("Priority",true,"60px"),
	new listboxHeaderWidthObj("Status",true,"60px"),
	new listboxHeaderWidthObj("User",true,"60px"),
	new listboxHeaderWidthObj("OS",true,"40px"),
	new listboxHeaderWidthObj("OSC",true,"60px"),
};

class tkslbClick implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		// save prev ticket meta when tick stat = new
		if(glob_ticket_status.equals("NEW")) doFunc(updatet_b);

		isel = event.getReference();
		glob_selected_ticket = lbhand.getListcellItemLabel(isel,0);
		glob_ticket_status = lbhand.getListcellItemLabel(isel,4);
		global_selected_customername = lbhand.getListcellItemLabel(isel,2);

		disb = false;
		if(!glob_ticket_status.equals("NEW")) disb = true;
		disableButts(disb);

		rsd = false;
		if(glob_ticket_status.equals("CLOSE")) rsd = true;
		upreso_b.setDisabled(rsd); // update resolution

		vequiprma_b.setVisible(false);
		showTicketMetadata(glob_selected_ticket);
	}
}
tkslclicker = new tkslbClick();

void showTickets()
{
	scht = kiboo.replaceSingleQuotes(searhtxt_tb.getValue()).trim();
	sdate = kiboo.getDateFromDatebox(startdate);
    edate = kiboo.getDateFromDatebox(enddate);

	Listbox newlb = lbhand.makeVWListbox_Width(tickets_holder, tkslb_headers, "tickets_lb", 5);

	scsql = "";
	if(!scht.equals("")) scsql = "and cust_name like '%" + scht + "%' ";

	sqlstm = "select origid,calldatetime,cust_name,priority,tstatus,createdby,os_id,os_resolvedate from rw_helptickets " +
	"where calldatetime between '" + sdate + " 00:00:00' and '" + edate + " 23:59:00' " +
	scsql + "order by origid";

	screcs = sqlhand.gpSqlGetRows(sqlstm);
	if(screcs.size() == 0) return;
	newlb.setRows(22);
	newlb.setMold("paging");
	newlb.addEventListener("onSelect",tkslclicker);
	ArrayList kabom = new ArrayList();
	for(dpi : screcs)
	{
		kabom.add(dpi.get("origid").toString());
		kabom.add(dpi.get("calldatetime").toString().substring(0,10));
		kabom.add( kiboo.checkNullString(dpi.get("cust_name")) );
		tprio = kiboo.checkNullString(dpi.get("priority"));
		kabom.add(tprio);
		kabom.add(kiboo.checkNullString(dpi.get("tstatus")));
		kabom.add(kiboo.checkNullString(dpi.get("createdby")));
		kabom.add(kiboo.checkNullString(dpi.get("os_id")));
		osre = (dpi.get("os_resolvedate") == null) ? "" : dtf2.format( dpi.get("os_resolvedate") );
		kabom.add(osre);

		mysty = "";
		if(tprio.equals("CRITICAL")) mysty = "font-size:9px;" + CRITICAL_BACKGROUND;
		if(tprio.equals("URGENT")) mysty = "font-size:9px;" + URGENT_BACKGROUND;

		lbhand.insertListItems(newlb,kiboo.convertArrayListToStringArray(kabom),"false",mysty);
		kabom.clear();
	}
}

