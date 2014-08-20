import java.lang.Float;
import groovy.sql.Sql;
import org.zkoss.zk.ui.*;
import org.zkoss.zk.zutl.*;
import org.zkoss.util.media.AMedia;

// 10/07/2013: moved 'em funcs here TODO byte-compile later

Object vMakeWindow(Object ipar, String ititle, String iborder, String ipos, String iw, String ih)
{
	rwin = new Window(ititle,iborder,true);
	rwin.setWidth(iw);
	rwin.setHeight(ih);
	rwin.setPosition(ipos);
	rwin.setParent(ipar);
	rwin.setMode("overlapped");
	return rwin;
}

void popuListitems_Data(ArrayList ikb, String[] ifl, Object ir)
{
	for(i=0; i<ifl.length; i++)
	{
		kk = ir.get(ifl[i]);
		if(kk == null) kk = "";
		else
		if(kk instanceof Date) kk = dtf2.format(kk);
		else
		if(kk instanceof Integer || kk instanceof Double) kk = nf0.format(kk);
		else
		if(kk instanceof Float) kk = kk.toString();
		ikb.add( kk );
	}
}

String[] getString_fromUI(Object[] iob)
{
	rdt = new String[iob.length];
	for(i=0; i<iob.length; i++)
	{
		rdt[i] = "";
		try {
		if(iob[i] instanceof Textbox || iob[i] instanceof Label) rdt[i] = kiboo.replaceSingleQuotes(iob[i].getValue().trim());
		if(iob[i] instanceof Listbox) rdt[i] = iob[i].getSelectedItem().getLabel();
		if(iob[i] instanceof Datebox) rdt[i] = dtf2.format( iob[i].getValue() );
		}
		catch (Exception e) {}
	}
	return rdt;
}

void populateUI_Data(Object[] iob, String[] ifl, Object ir)
{
	for(i=0;i<iob.length;i++)
	{
		try {
		if(iob[i] instanceof Textbox || iob[i] instanceof Label)
		{
			kk = ir.get(ifl[i]);
			if(kk == null) kk = "";
			else
			if(kk instanceof Date) kk = dtf.format(kk);
			else
			if(kk instanceof Integer || kk instanceof Double) kk = kk.toString();
			else
			if(kk instanceof Float) kk = nf2.format(kk);

			iob[i].setValue(kk);
		}

		if(iob[i] instanceof Listbox) lbhand.matchListboxItems( iob[i], kiboo.checkNullString( ir.get(ifl[i]) ) );
		if(iob[i] instanceof Datebox) iob[i].setValue( ir.get(ifl[i]) );
		} catch (Exception e) {}
	}
}

void clearUI_Field(Object[] iob)
{
	for(i=0; i<iob.length; i++)
	{
		if(iob[i] instanceof Textbox || iob[i] instanceof Label) iob[i].setValue("");
		if(iob[i] instanceof Datebox) kiboo.setTodayDatebox(iob[i]);
		if(iob[i] instanceof Listbox) iob[i].setSelectedIndex(0);
	}
}

int getWeekOfMonth(String thedate)
{
	sqlstm = "SELECT DATEPART(WEEK, '" + thedate + "') - DATEPART(WEEK, DATEADD(MM, " + 
	"DATEDIFF(MM,0,'" + thedate + "'), 0))+ 1 AS WEEK_OF_MONTH";

	krr = sqlhand.gpSqlFirstRow(sqlstm);
	if(krr == null) return -1;

	return (int)krr.get("WEEK_OF_MONTH");
}

// Lookup-func: get value1-value8 from lookup table by parent-name
String getFieldsCommaString(String iparents,int icol)
{
	aprs = luhand.getLookups_ByParent(iparents);
	retv = "";
	fld = "value" + icol.toString();
	for(di : aprs)
	{
		tpm = kiboo.checkNullString(di.get(fld));
		retv += tpm + ",";
	}

	retv = retv.replaceAll(",,",",");
	try {
	retv = retv.substring(0,retv.length()-1);
	} catch (Exception e) {}

	return retv;
}

// Merge 2 object-arrays into 1 - codes copied from some website
Object[] mergeArray(Object[] lst1, Object[] lst2)
{
	List list = new ArrayList(Arrays.asList(lst1));
	list.addAll(Arrays.asList(lst2));
	Object[] c = list.toArray();
	return c;
}

void blindTings(Object iwhat, Object icomp)
{
	itype = iwhat.getId();
	klk = iwhat.getLabel();
	bld = (klk.equals("+")) ? true : false;
	iwhat.setLabel( (klk.equals("-")) ? "+" : "-" );
	icomp.setVisible(bld);
}

void blindTings_withTitle(Object iwhat, Object icomp, Object itlabel)
{
	itype = iwhat.getId();
	klk = iwhat.getLabel();
	bld = (klk.equals("+")) ? true : false;
	iwhat.setLabel( (klk.equals("-")) ? "+" : "-" );
	icomp.setVisible(bld);

	itlabel.setVisible((bld == false) ? true : false );
}

void downloadFile(Div ioutdiv, String ifilename, String irealfn)
{
	File f = new File(irealfn);
	fileleng = f.length();
	finstream = new FileInputStream(f);
	byte[] fbytes = new byte[fileleng];
	finstream.read(fbytes,0,(int)fileleng);

	AMedia amedia = new AMedia(ifilename, "xls", "application/vnd.ms-excel", fbytes);
	Iframe newiframe = new Iframe();
	newiframe.setParent(ioutdiv);
	newiframe.setContent(amedia);
}

void activateModule(String iplayg, String parentdiv_name, String winfn, String windId, String uParams, Object uAO)
{
	Include newinclude = new Include();
	newinclude.setId(windId);

	includepath = winfn + "?myid=" + windId + "&" + uParams;
	newinclude.setSrc(includepath);

	sechand.setUserAccessObj(newinclude, uAO); // securityfuncs.zs

	Div contdiv = Path.getComponent(iplayg + parentdiv_name);
	newinclude.setParent(contdiv);

} // activateModule()

// Use to refresh 'em checkboxes labels -- can be used for other mods
// iprefix: checkbox id prefix, inextcount: next id count
void refreshCheckbox_CountLabel(String iprefix, int inextcount)
{
	count = 1;
	for(i=1;i<inextcount; i++)
	{
		bci = iprefix + i.toString();
		icb = items_grid.getFellowIfAny(bci);
		if(icb != null)
		{
			icb.setLabel(count + ".");
			count++;
		}
	}
}

// itype: 1=width, 2=height
gpMakeSeparator(int itype, String ival, Object iparent)
{
	sep = new Separator();
	if(itype == 1) sep.setWidth(ival);
	if(itype == 2) sep.setHeight(ival);
	sep.setParent(iparent);
}

Textbox gpMakeTextbox(Object iparent, String iid, String ivalue, String istyle, String iwidth)
{
	Textbox retv = new Textbox();
	if(!iid.equals("")) retv.setId(iid);
	if(!istyle.equals("")) retv.setStyle(istyle);
	if(!ivalue.equals("")) retv.setValue(ivalue);
	if(!iwidth.equals("")) retv.setWidth(iwidth);
	retv.setParent(iparent);
	return retv;
}

Button gpMakeButton(Object iparent, String iid, String ilabel, String istyle, Object iclick)
{
	Button retv = new Button();
	if(!istyle.equals("")) retv.setStyle(istyle);
	if(!ilabel.equals("")) retv.setLabel(ilabel);
	if(!iid.equals("")) retv.setId(iid);
	if(iclick != null) retv.addEventListener("onClick", iclick);
	retv.setParent(iparent);
	return retv;
}

Label gpMakeLabel(Object iparent, String iid, String ivalue, String istyle)
{
	Label retv = new Label();
	if(!iid.equals("")) retv.setId(iid);
	if(!istyle.equals("")) retv.setStyle(istyle);
	retv.setValue(ivalue);
	retv.setParent(iparent);
	return retv;
}

Checkbox gpMakeCheckbox(Object iparent, String iid, String ilabel, String istyle)
{
	Checkbox retv = new Checkbox();
	if(!iid.equals("")) retv.setId(iid);
	if(!istyle.equals("")) retv.setStyle(istyle);
	if(!ilabel.equals("")) retv.setLabel(ilabel);
	retv.setParent(iparent);
	return retv;
}

// Add something to rw_systemaudit, datecreated will have time too
// ilinkc=linking_code, isubc=linking_sub, iwhat=audit_notes
void add_RWAuditLog(String ilinkc, String isubc, String iwhat, String iuser)
{
	todaydate =  kiboo.todayISODateTimeString();
	sqlstm = "insert into rw_systemaudit (datecreated,linking_code,linking_sub,audit_notes,username) values " +
	"('" + todaydate + "','" + ilinkc + "','" + isubc + "','" + iwhat + "','" + iuser + "')";
	sqlhand.gpSqlExecuter(sqlstm);
}

Object getStockItem_rec(String istkcode)
{
	sqlstm = "select * from stockmasterdetails where stock_code='" + istkcode + "'";
	return sqlhand.gpSqlFirstRow(sqlstm);
}

boolean checkStockExist(String istkc)
{
	sqlstm = "select id from stockmasterdetails where stock_code='" + istkc + "'";
	krr = sqlhand.gpSqlFirstRow(sqlstm);
	retval = false;
	if(krr != null) retval = true;
	return retval;
}

Object getFocus_CustomerRec(String icustid)
{
	focsql = sqlhand.rws_Sql();
	if(focsql == null) return null;
	sqlstm = "select cust.name,cust.code,cust.code2, " +
	"custd.address1yh, custd.address2yh, custd.address3yh, custd.address4yh, " +
	"custd.telyh, custd.faxyh, custd.contactyh, custd.deliverytoyh, " +
	"custd.manumberyh, custd.rentaltermyh, custd.interestayh, " +
	"custd.credit4yh, custd.credit5yh, custd.creditlimityh, " +
	"custd.salesrepyh,custd.interestayh,custd.emailyh, cust.type from mr000 cust " +
	"left join u0000 custd on custd.extraid = cust.masterid " +
	"where cust.masterid=" + icustid;
	retval = focsql.firstRow(sqlstm);
	focsql.close();
	return retval;
}

String getFocus_CustomerName(String icustid)
{
	if(icustid.equals("")) return "NEW";
	focsql = sqlhand.rws_Sql();
	if(focsql == null) return "NEW";
	sqlstm = "select cust.name from mr000 cust where cust.masterid=" + icustid;
	retval = focsql.firstRow(sqlstm);
	focsql.close();
	if(retval == null) return "NEW";
	return retval.get("name");
}

Object getGCO_rec(String iwhat)
{
	sqlstm = "select * from rw_goodscollection where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getGRN_rec(String iwhat)
{
	sqlstm = "select * from tblgrnmaster where id=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getHelpTicket_rec(String iwhat)
{
	sqlstm = "select * from rw_helptickets where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getLocalRMA_rec(String iwhat)
{
	sqlstm = "select * from rw_localrma where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getLocalRMAItem_rec(String iwhat)
{
	sqlstm = "select * from rw_localrma_items where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getLC_rec(String iwhat)
{
	sqlstm = "select * from rw_leasingcontract where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getLCAsset_rec(String iwhat)
{
	sqlstm = "select * from rw_leaseequipments where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getLCEquips_rec(String iwhat)
{
	sqlstm = "select * from rw_lc_equips where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getRentalItems_build(String iwhat)
{
	sqlstm = "select * from stockrentalitems_det where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getPickPack_rec(String iwhat)
{
	sqlstm = "select * from rw_pickpack where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getRWJob_rec(String iwhat)
{
	sqlstm = "select * from rw_jobs where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getBOM_rec(String iwhat)
{
	sqlstm = "select * from stockrentalitems where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getDO_rec(String iwhat)
{
	sqlstm = "select * from rw_deliveryorder where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getDispatchManifest_rec(String iwhat)
{
	sqlstm = "select * from rw_dispatchmanif where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getOfficeItem_rec(String iwhat)
{
	sqlstm = "select * from rw_officeitems where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getSoftwareLesen_rec(String iid)
{
	sqlstm = "select * from rw_clientswlicenses where origid=" + iid;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getPR_rec(String iwhat)
{
	sqlstm = "select * from purchaserequisition where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getSendout_rec(String iwhat)
{
	sqlstm = "select * from rw_sendouttracker where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getQuotation_rec(String iwhat)
{
	sqlstm = "select * from rw_quotations where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getCheqRecv_rec(String iwhat)
{
	sqlstm = "select * from rw_cheqrecv where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getDrawdownAssignment_rec(String iwhat)
{
	sqlstm = "select * from rw_assigned_rwi where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getActivitiesContact_rec(String iwhat)
{
	sqlstm = "select * from rw_activities_contacts where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getActivity_rec(String iwhat)
{
	sqlstm = "select * from rw_activities where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getLCNew_rec(String iwhat)
{
	sqlstm = "select * from rw_lc_records where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getReservation_Rec(String iwhat)
{
	sqlstm = "select * from rw_stockreservation where origid=" + iwhat;
	return sqlhand.gpSqlFirstRow(sqlstm);
}

Object getEqReqStat_rec(String iwhat)
{
	sqlstm = "select * from reqthings_stat where parent_id='"+ iwhat + "'";
	return sqlhand.rws_gpSqlFirstRow(sqlstm);
}

Object getFC_indta_rec(String iwhat)
{
	sqlstm = "select * from indta where salesid=" + iwhat;
	return sqlhand.rws_gpSqlFirstRow(sqlstm);
}

boolean existRW_inLCTab(String iwhat)
{
	sqlstm = "select top 1 origid from rw_lc_records where rwno='" + iwhat + "' or lc_id='" + iwhat + "'";
	return (sqlhand.gpSqlFirstRow(sqlstm) == null) ? false : true;
}

BOM_JOBID = 1; // BOM link to job-id
PICKLIST_JOBID = 2; // pick-list link to job-id
BOM_DOID = 3; // BOM link to DO
PICKLIST_DOID = 4; // pick-list link to DO
DO_MANIFESTID = 5; // DO link to manifest
PR_JOB = 6; // PR link to job
//DO_JOBPICKID = 6; // DO link to job-id

// General purpose to return string of other things with linking job-id (ijid)
String getLinkingJobID_others(int itype, String ijid)
{
	retv = tablen = "";
	lnkid = "job_id";

	switch(itype)
	{
		case BOM_JOBID :
		case BOM_DOID :
			tablen = "stockrentalitems";
			break;
		case PICKLIST_JOBID :
		case PICKLIST_DOID :
			tablen = "rw_pickpack";
			break;
		case DO_MANIFESTID :
			tablen = "rw_deliveryorder";
			lnkid = "manif_id";
			break;
	}

	if(itype == BOM_DOID || itype == PICKLIST_DOID) lnkid = "do_id";

	if(!tablen.equals(""))
	{
		sqlstm = "select origid from " + tablen + " where " + lnkid + "=" + ijid;
		krs = sqlhand.gpSqlGetRows(sqlstm);
		if(krs.size() != 0)
		{
			for(d : krs)
			{
				retv += d.get("origid").toString() + ",";
			}
			try {
			retv = retv.substring(0,retv.length()-1);
			} catch (Exception e) {}
		}
	}

	return retv;
}

// DOs link to bom/picklist link to job - can be used for other mods to comma-string something
// itype: 1=picklist, 2=boms, 3=PR
String getDOLinkToJob(int itype, String iorigids)
{
	retv = sqlstm = "";

	if(!iorigids.equals("") && itype == 1)
	{
		sqlstm = "select distinct do.origid as doid from rw_deliveryorder do " +
		"left join rw_pickpack ppl on ppl.do_id = do.origid " +
		"where ppl.origid in (" + iorigids + ")";
	}

	if(!iorigids.equals("") && itype == 2)
	{
		sqlstm = "select distinct do.origid as doid from rw_deliveryorder do " +
		"left join stockrentalitems sri on sri.do_id = do.origid " +
		"where sri.origid in (" + iorigids + ")";
	}

	if(!iorigids.equals("") && itype == 3)
	{
		sqlstm = "select distinct pr.origid as doid from purchaserequisition pr " +
		"where pr.job_id=" + iorigids;
	}

	if(!sqlstm.equals(""))
	{
		rcs = sqlhand.gpSqlGetRows(sqlstm);
		if(rcs.size() != 0)
		{
			for(d : rcs)
			{
				retv += d.get("doid") + ",";
			}
			try { retv = retv.substring(0,retv.length()-1); } catch (Exception e) {}
		}
	}
	return retv;
	//return sqlstm;
}

// Populate a listbox with usernames from portaluser
void populateUsernames(Listbox ilb, String discardname)
{
	sqlstm = "select username from portaluser where username<>'" + discardname + "' and deleted=0 and locked=0 order by username";
	recs = sqlhand.gpSqlGetRows(sqlstm);
	if(recs.size() == 0) return;
	ArrayList kabom = new ArrayList();
	for( d : recs)
	{
		kabom.add( kiboo.checkNullString(d.get("username")) );
		lbhand.insertListItems(ilb,kiboo.convertArrayListToStringArray(kabom),"false","");
		kabom.clear();
	}
	ilb.setSelectedIndex(0);
}

