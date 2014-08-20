import org.victor.*;

// General purpose funcs for customerManager.zul

// To be used for audit or whatever
String FC6_custRecString(String iwhat)
{
	csr = getFocus_CustomerRec(iwhat);
	if(csr == null) return "FC6CUST DBERR";

	retv =
	 "adr1: " + kiboo.checkNullString(csr.get("address1yh")) +
	" adr2: " + kiboo.checkNullString(csr.get("address2yh")) +
	" adr3: " + kiboo.checkNullString(csr.get("address3yh")) +
	" adr4: " + kiboo.checkNullString(csr.get("address4yh")) +
	" code: " + kiboo.checkNullString(csr.get("code")) +
	" code2: " + kiboo.checkNullString(csr.get("code2")) +
	" tel: " + kiboo.checkNullString(csr.get("telyh")) +
	" fax: " + kiboo.checkNullString(csr.get("faxyh")) +
	" cont: " + kiboo.checkNullString(csr.get("contactyh")) +
	" dlvy: " + kiboo.checkNullString(csr.get("deliverytoyh")) +
	" eml: " + kiboo.checkNullString(csr.get("emailyh")) +
	" salr: " + kiboo.checkNullString(csr.get("salesrepyh")) +
	" manum: " + kiboo.checkNullString(csr.get("manumberyh")) +
	" rentrm: " + kiboo.checkNullString(csr.get("rentaltermyh")) +
	" intrst: " + kiboo.checkNullString(csr.get("interestayh")) +
	" bcyc: " + kiboo.checkNullString(csr.get("credit4yh")) +
	" finc: " + kiboo.checkNullString(csr.get("credit5yh")) +
	" crdl: " + ((csr.get("creditlimityh") == null) ? "0" :  csr.get("creditlimityh").toString());

	return retv;
}

// Clear popup input fields. itype: 1=address, 2=contact
void clearFields(int itype)
{
	Object[] obk = { e_site_desc, e_contact, e_designation, e_contact2, e_designation2, e_contact3, e_designation3,
		e_address1, e_address2, e_address3, e_address4, e_category
	};
	
	Object[] obk2 = { f_contact, f_email, f_phone, f_cphone, f_category, f_designation };
	
	switch(itype)
	{
		case 1:
			for(i=0; i<obk.length; i++)
			{
				if(obk[i] instanceof Textbox) obk[i].setValue("");
				if(obk[i] instanceof Listbox) obk[i].setSelectedIndex(0);
			}
			break;
		case 2:
			for(i=0; i<obk2.length; i++)
			{
				if(obk2[i] instanceof Textbox) obk2[i].setValue("");
				if(obk2[i] instanceof Listbox) obk2[i].setSelectedIndex(0);
			}
			break;
	}
}

// Set itype: 1=address, 2=contact, iwhat: 1=insert, 2=update
void setPopFunc(int itype, int iwhat)
{
	btnlbl = (iwhat == 1) ? "Add" : "Update";
	clrbit = (iwhat == 1) ? true : false;

	switch(itype)
	{
		case 1: // address
			addr_type.setValue(iwhat.toString());
			addaddress_b.setLabel(btnlbl);
			addaddrclr_b.setVisible(clrbit);
			break;

		case 2: // contact
			cont_type.setValue(iwhat.toString());
			addcontact_b.setLabel(btnlbl);
			addcontclr_b.setVisible(clrbit);
			break;
	}
}

void fillPopup(int itype, String ioid)
{
	String[] cs1flds = { "site_desc", "contact", "designation", "contact2", "designation2", "contact3", "designation3",
	"address1", "address2", "address3", "address4", "category"
	};

	Object[] obj1 = { e_site_desc, e_contact, e_designation, e_contact2, e_designation2, e_contact3, e_designation3,
	e_address1, e_address2, e_address3, e_address4, e_category
	};

	String[] cs2flds = { "contact", "email", "phone", "cphone", "designation", "category" };
	Object[] obj2 = { f_contact, f_email, f_phone, f_cphone, f_designation, f_category };

	switch(itype)
	{
		case 1: // address
			sqlstm = "select * from rw_custextaddr where origid=" + ioid;
			fr = sqlhand.gpSqlFirstRow(sqlstm);
			if(fr == null) { guihand.showMessageBox("DBERR: Cannot access extra addresses table.."); return; }

			for(i=0; i<obj1.length; i++)
			{
				if(obj1[i] instanceof Textbox) obj1[i].setValue( kiboo.checkNullString( fr.get(cs1flds[i]) ) );
				if(obj1[i] instanceof Listbox) lbhand.matchListboxItems(obj1[i], kiboo.checkNullString( fr.get(cs1flds[i]) ) );
			}
			break;
		case 2: // contact
			sqlstm = "select * from rw_custextcontact where origid=" + ioid;
			fr = sqlhand.gpSqlFirstRow(sqlstm);
			if(fr == null) { guihand.showMessageBox("DBERR: Cannot access extra contacts table.."); return; }

			for(i=0; i<obj2.length; i++)
			{
				if(obj2[i] instanceof Textbox) obj2[i].setValue( kiboo.checkNullString( fr.get(cs2flds[i]) ) );
				if(obj2[i] instanceof Listbox) lbhand.matchListboxItems(obj2[i], kiboo.checkNullString( fr.get(cs2flds[i]) ) );
			}
			break;
	}
}

Object[] extcontshds =
{
	new listboxHeaderWidthObj("origid",false,""),
	new listboxHeaderWidthObj("Contact",true,""),
	new listboxHeaderWidthObj("Dsgn",true,""),
	new listboxHeaderWidthObj("Email",true,""),
	new listboxHeaderWidthObj("Phone",true,""),
	new listboxHeaderWidthObj("H/Phone",true,""),
	new listboxHeaderWidthObj("Category",true,"70px"),
	new listboxHeaderWidthObj("Last.Up",true,"70px"),
};

class extcontsclk implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(org.zkoss.zk.ui.event.Event event) throws UiException
	{
		isel = event.getReference();
		glob_sel_econt = lbhand.getListcellItemLabel(isel,0);
	}
}
extcoclkier = new extcontsclk();

class extcontsdclk implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();
		glob_sel_econt = lbhand.getListcellItemLabel(isel,0);

		setPopFunc(2,2); // update contact
		clearFields(2);
		fillPopup(2,glob_sel_econt);
		extcontact_pop.open(isel);
	}
}

void showCustomerExtraContacts(String iprid)
{
	Listbox newlb = lbhand.makeVWListbox_Width(extcontacts_holder, extcontshds, "extcontacts_lb", 5);
	sqlstm = "select origid,contact,email,cphone,phone,datecreated,category,designation,deleted from rw_custextcontact " +
	"where parent_id='" + iprid + "'";
	sqlstm += (useraccessobj.accesslevel != 9) ? " and (deleted is null or deleted=0)" : "";
	crecs = sqlhand.gpSqlGetRows(sqlstm);
	if(crecs.size() == 0) return;
	newlb.setRows(20);
	newlb.setMold("paging");
	newlb.addEventListener("onSelect", extcoclkier);
	ArrayList kabom = new ArrayList();
	for(d : crecs)
	{
		kabom.add( d.get("origid").toString() );

		bdel = "";
		if(useraccessobj.accesslevel == 9)
			bdel = (d.get("deleted") == null) ? " [A]" : (d.get("deleted")) ? " [X]" : " [A]";

		kabom.add( d.get("contact") + bdel );
		kabom.add( kiboo.checkNullString(d.get("designation")) );
		kabom.add( d.get("email") );
		kabom.add( d.get("phone") );
		kabom.add( d.get("cphone") );
		kabom.add( d.get("category") );
		kabom.add( dtf2.format(d.get("datecreated")) );

		strarray = kiboo.convertArrayListToStringArray(kabom);	
		lbhand.insertListItems(newlb,strarray,"false","");
		kabom.clear();
	}

	dc_obj = new extcontsdclk();
	lbhand.setDoubleClick_ListItems(newlb, dc_obj);
}

Object[] extcontshds2 =
{
	new listboxHeaderWidthObj("Contact",true,""),
	new listboxHeaderWidthObj("Dsgn",true,""),
	new listboxHeaderWidthObj("Email",true,""),
	new listboxHeaderWidthObj("Phone",true,""),
	new listboxHeaderWidthObj("H/Phone",true,""),
	new listboxHeaderWidthObj("Category",true,"70px"),
	new listboxHeaderWidthObj("Last.Up",true,"70px"),
	new listboxHeaderWidthObj("origid",false,""),
};

void showCustomerExtraContacts_2(String iprid, Div idiv, String ilbid)
{
	Listbox newlb = lbhand.makeVWListbox_Width(idiv, extcontshds2, ilbid, 5);
	sqlstm = "select origid,contact,email,cphone,phone,datecreated,category,designation,deleted from rw_custextcontact " +
	"where parent_id='" + iprid + "'";
	sqlstm += (useraccessobj.accesslevel != 9) ? " and (deleted is null or deleted=0)" : "";
	crecs = sqlhand.gpSqlGetRows(sqlstm);
	if(crecs.size() == 0) return;
	newlb.setRows(10);
	newlb.setMold("paging");
	newlb.setMultiple(true);
	newlb.setCheckmark(true);
	//newlb.addEventListener("onSelect", new extcontsclk());
	ArrayList kabom = new ArrayList();
	for(d : crecs)
	{
		bdel = "";
		if(useraccessobj.accesslevel == 9)
			bdel = (d.get("deleted") == null) ? " [A]" : (d.get("deleted")) ? " [X]" : " [A]";

		kabom.add( d.get("contact") + bdel );
		kabom.add( kiboo.checkNullString(d.get("designation")) );
		kabom.add( d.get("email") );
		kabom.add( d.get("phone") );
		kabom.add( d.get("cphone") );
		kabom.add( d.get("category") );
		kabom.add( dtf2.format(d.get("datecreated")) );
		kabom.add( d.get("origid").toString() );

		strarray = kiboo.convertArrayListToStringArray(kabom);	
		lbhand.insertListItems(newlb,strarray,"false","");
		kabom.clear();
	}

	//dc_obj = new extcontsdclk();
	//lbhand.setDoubleClick_ListItems(newlb, dc_obj);
}

Object[] extaddrhds =
{
	new listboxHeaderWidthObj("origid",false,""),
	new listboxHeaderWidthObj("Site",true,""),
	new listboxHeaderWidthObj("Address",true,""),
	new listboxHeaderWidthObj("Category",true,"70px"),
	new listboxHeaderWidthObj("Last.Up",true,"70px"),
};

class extaddrclk implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(org.zkoss.zk.ui.event.Event event) throws UiException
	{
		isel = event.getReference();
		glob_sel_eaddr = lbhand.getListcellItemLabel(isel,0);
	}
}

class extaddrdclk implements org.zkoss.zk.ui.event.EventListener
{
	public void onEvent(Event event) throws UiException
	{
		isel = event.getTarget();
		glob_sel_eaddr = lbhand.getListcellItemLabel(isel,0);
		setPopFunc(1,2); // update address
		clearFields(1);
		fillPopup(1,glob_sel_eaddr);
		extaddr_pop.open(isel);
	}
}
exadrckler = new extaddrdclk();

void showCustomerExtraAddresses(String iprid)
{
	Listbox newlb = lbhand.makeVWListbox_Width(extaddrs_holder, extaddrhds, "extaddrs_lb", 5);
	sqlstm = "select origid,site_desc,address1,address2,address3,address4,datecreated,category,deleted from rw_custextaddr " +
	"where parent_id='" + iprid + "'";

	sqlstm += (useraccessobj.accesslevel != 9) ? " and (deleted is null or deleted=0)" : "";

	crecs = sqlhand.gpSqlGetRows(sqlstm);
	if(crecs.size() == 0) return;
	newlb.setRows(20);
	newlb.setMold("paging");
	newlb.addEventListener("onSelect", exadrckler);
	ArrayList kabom = new ArrayList();

	for(d : crecs)
	{
		kabom.add( d.get("origid").toString() );

		bdel = "";
		if(useraccessobj.accesslevel == 9)
			bdel = (d.get("deleted") == null) ? " [A]" : (d.get("deleted")) ? " [X]" : " [A]";

		kabom.add( d.get("site_desc") + bdel );

		adrs = d.get("address1") + " \n" + d.get("address2") + 
		" \n" + d.get("address3") + " \n" + d.get("address4");

		kabom.add(adrs);
		kabom.add( d.get("category") );
		kabom.add( dtf2.format(d.get("datecreated")) );

		strarray = kiboo.convertArrayListToStringArray(kabom);	
		lbhand.insertListItems(newlb,strarray,"false","");
		kabom.clear();
	}

	dc_obj = new extaddrdclk();
	lbhand.setDoubleClick_ListItems(newlb, dc_obj);
}


