// Reporting and data-export Funcs for rwpurchaseReq

// exec dbo.getWeekOfMonth @thedate = '2013-11-28'

// custom func to sum-up items qty*price
float calcPR_total(String[] iqty, String[] iuprice)
{
	rtot = 0.0;
	for(i=0;i<iqty.length;i++)
	{
		try {
		rtot += Float.parseFloat(iqty[i]) * Float.parseFloat(iuprice[i]);
		} catch (Exception e) {}
	}
	return (float)rtot;
}

int getWeekOfDay_java(java.sql.Timestamp datey)
{
	if(datey == null) return 0;
	Date dt1 = dtf2.parse(dtf2.format(datey));
	Calendar ca1 = Calendar.getInstance();
	ca1.setTime(dt1);
	ca1.setMinimalDaysInFirstWeek(1);
	return ca1.get(Calendar.WEEK_OF_MONTH);
}

void rep_PaymentDueWeek(String istart, String iend)
{
	sqlstm = "select origid,datecreated,supplier_name,creditterm,pr_qty,pr_unitprice,paydue_date from purchaserequisition " +
	"where datecreated between '" + istart + " 00:00:00' and '" + iend + " 23:59:00' and pr_status='APPROVE' " +
	"order by paydue_date" ;

	recs = sqlhand.gpSqlGetRows(sqlstm);
	if(recs.size() == 0) { guihand.showMessageBox("No purchasing records found.."); return; }

	Workbook wb = new HSSFWorkbook();
	Sheet sheet = wb.createSheet("PAY_WEEK");
	Font wfont = wb.createFont();
	wfont.setFontHeightInPoints((short)8);
	wfont.setFontName("Arial");

	String[] ihds = { "PR.ID","DATED","SUPPLIER","PAYMENT_DUE","WEEK 0","WEEK 1","WEEK 2","WEEK 3", "WEEK 4", "WEEK 5" };
	for(i=0; i<ihds.length; i++)
	{
		excelInsertString( sheet, 0, 0+i, ihds[i]);
	}

	sum0 = sum1 = sum2 = sum3 = sum4 = sum5 = 0.0;

	rwcount = 1;
	for(d : recs)
	{
		excelInsertString( sheet,rwcount, 0, d.get("origid").toString() );
		excelInsertString( sheet,rwcount, 1, dtf2.format(d.get("datecreated")) );
		excelInsertString( sheet,rwcount, 2, d.get("supplier_name") );
		excelInsertString( sheet,rwcount, 3, (d.get("paydue_date")==null) ? "" : dtf2.format(d.get("paydue_date")) );

		wkd = getWeekOfDay_java(d.get("paydue_date"));
		sume = calcPR_total(sqlhand.clobToString(d.get("pr_qty")).split("~"),
		sqlhand.clobToString(d.get("pr_unitprice")).split("~"));
		
		switch(wkd)
		{
			case 1 : sum1 += sume; break;
			case 2 : sum2 += sume; break;
			case 3 : sum3 += sume; break;
			case 4 : sum4 += sume; break;
			case 5 : sum5 += sume; break;
			default: sum0 += sume; break;
		}

		excelInsertNumber( sheet, rwcount, 4 + wkd , sume.toString() );
		rwcount++;
	}

	// put all 'em sum-ups
	excelInsertString( sheet, rwcount, 3, "TOTAL");
	excelInsertNumber( sheet, rwcount, 4 , nf2.format(sum0) );
	excelInsertNumber( sheet, rwcount, 5 , nf2.format(sum1) );
	excelInsertNumber( sheet, rwcount, 6 , nf2.format(sum2) );
	excelInsertNumber( sheet, rwcount, 7 , nf2.format(sum3) );
	excelInsertNumber( sheet, rwcount, 8 , nf2.format(sum4) );
	excelInsertNumber( sheet, rwcount, 9 , nf2.format(sum5) );

	jjfn = "paymentdueweek.xls";
	outfn = session.getWebApp().getRealPath("tmp/" + jjfn);
	FileOutputStream fileOut = new FileOutputStream(outfn);
	wb.write(fileOut); // Write Excel-file
	fileOut.close();

	downloadFile(kasiexport,jjfn,outfn); // rwsqlfuncs.zs TODO need to move this
}

