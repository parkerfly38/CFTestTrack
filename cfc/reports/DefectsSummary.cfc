component implements="CFTestTrack.cfc.IReports" 
{
    variables.reportid = 0;
    variables.reportname = "";
    variables.ReportOptions = StructNew();
    variables.AccessAndScheduling = StructNew();
    variables.projectId = Session.ProjectID;

    objData = createObject("component", "CFTestTrack.cfc.Data");

    public DefectsSummary function init(required numeric reportid, required string reportname, required struct reportoptions, required struct accessandscheduling, required numeric projectid) {
		variables.reportid = arguments.reportid;
		variables.ReportName = arguments.reportname;
		variables.ReportOptions = arguments.reportoptions;
		variables.AccessAndScheduling = arguments.accessandscheduling;
        variables.projectid = arguments.projectid;
		return this;
	}

    public string function getReportTypeName()
    {
        return "Defects Summary";
    }

	public string function getGroup()
    {
        return "Defects";
    }

	public string function getAuthor()
    {
        return "Brian Kresge, MBA";
    }
	public string function getVersion()
    {
        return "1.0";
    }
	public numeric function getReportId()
    {
        return variables.reportid;
    }
	
	public string function getReportName()
    {
        return variables.reportname;
    }

	public string function getReportDescription()
    {
        return "Highlights defect summary for selected date range.";
    }
	
	public struct function getReportOptions()
	{
		if ( structIsEmpty(variables.ReportOptions) ) {
			variables.ReportOptions.GroupingAndChanges = StructNew();
			variables.ReportOptions.GroupingAndChanges.IncludeChanges = "New,Updated";
			variables.ReportOptions.TimeFrame = "Today";
			variables.ReportOptions.TestScenarios = ""; // list
		}
		return variables.ReportOptions;
	}

	public struct function getAccessAndScheduling()
    {
        if ( structIsEmpty(variables.AccessAndScheduling) )
		{
			variables.AccessAndScheduling.AccessBy = Session.UserIDInt;
			variables.AccessAndScheduling.CreateReport = "Once";
			variables.AccessAndScheduling.Email = StructNew();
			variables.AccessAndScheduling.Email.NotifyMe = true;
			variables.AccessAndScheduling.Email.SendLinkToUserIds = "";
			variables.AccessAndScheduling.Email.SendAsAttachmentTo = "";
			variables.AccessAndScheduling.StartDate = DateFormat(Now(),"YYYY-MM-DD");
			variables.AccessAndScheduling.StartTime = "17:00";
		}
		return variables.AccessAndScheduling;
    }
	
	public void function setReportOptions(required struct reportoptions)
	{
		variables.ReportOptions = arguments.reportoptions;
	}

	public void function setAccessAndScheduling(required struct accessandscheduling)
	{
		variables.AccessAndScheduling = arguments.accessandscheduling;
	}
	
	public string function getFormFields()
    {
        formbody = 	"<script type='text/javascript'>";
		formbody &= "$(document).ready(function() { $('.selectpicker').selectpicker(); });";
		formbody &= "</script>";
		formbody &= "<ul class='nav nav-tabs'>";
		formbody &=	"<li class='active'><a data-toggle='tab' href='##Options'>Options</a></li>";
		formbody &= "<li><a data-toggle='tab' href='##Access'>Access and Scheduling</a></li>";
		formbody &= "</ul>";
		formbody &= "<div class='tab-content'>";
		formbody &= "<div id='Options' class='tab-pane fade in active'>";
		formbody &= "<div class='input-group'>";
		formbody &= "<label for='timeframe'>Use the following time frame:</label><br />";
		formbody &= "<select id='timeframe' name='timeframe' class='selectpicker' data-style='btn-info btn-xs'><option value='Today' selected>Today</option><option value='Week'>This Week</option><option value='Month'>This Month</option><option value='All'>All Time</option></select></label>";
		formbody &= "</div>";
        formbody &= "<div class='input-group'>";
        formbody &= "<label for='scenarios'>Select from the following scenarios:</label><br />";
        formbody &= "<select id='scenarios' name='scenarios' multiple>";
        arrScenarios = objData.getScenarioByProjectID(variables.projectid);
        if (ArrayLen(arrScenarios) gt 0)
        {
            for( i = 1; i LTE ArrayLen(arrScenarios); i++)
            {
                formbody &= "<option value='" & arrScenarios[i].getId() & "'>" & arrScenarios[i].getTestScenario() & "</option>"; 
            }
        }
        formbody &= "</select>";
        formbody &= "</div></div>";
		formbody &= "<div id='Access' class='tab-pane fade in'>";
		formbody &= "<h5>This report can be viewed by:</h5>";
		formbody &= "<label><input type='radio' value='" & Session.UserIDInt & "' id='AccessBy' name='AccessBy'> You</label><br />";
		formbody &= "<label><input type='radio' value='0' id='AccessBy' name='AccessBy'> Everyone</label>";
		formbody &= "<h5>Create (and Schedule):</h5>";
		formbody &= "<select id='createreport' name='createreport' class='selectpicker' data-style='btn-info'><option value='once'>Once</option><option value='weekly'>Weekly</option><option value='monthly'>Monthly</option></select>&nbsp;&nbsp;";
		formbody &= "<select id='starttime' name='starttime' class='selectpicker' data-style='btn-info'>";
		for (i = 0; i LTE 23; i++ ) {
			formbody &= "<option>" & i & ":00</option>";
		}
		formbody &= "</select>";
		formbody &= "<h5>Send report to:</h5>";
		formbody &= "<div class='input-group'><label><input type='checkbox' id='notifyme' name='notifyme' value='true'> You</label><br />";
		formbody &= "<label for='sendlintousers'>Email link to the following addresses (separate by comma):</label>";
		formbody &= "<textarea id='sendlinktouserids' name='sendlinktouserids' class='form-control' rows='4'></textarea>";
		formbody &= "<label for='sendasattachmentto'>Email link to the following addresses as attachment (separate by comma):</label>";
		formbody &= "<textarea id='sendasattachmentto' name='sendasattachmentto' class='form-control' rows='4'></textarea>";
		formbody &= "</div></div></div>";
		return formbody;
    }
	public string function getJSONFormDataForPost()
    {
        sReturn =	"var reportOptions = " & serializeJSON(getReportOptions()) & chr(13) & chr(10);
		sReturn &=	"var reportAandS = " & serializeJSON(getAccessAndScheduling()) & chr(13) & chr(10);
		sReturn &=	"reportOptions.GROUPINGANDCHANGES.INCLUDECHANGES = $('##includechanges:checked').map(function() {return this.value;}).get().join(',');" & chr(13) & chr(10);
		sReturn &=	"reportOptions.TIMEFRAME = $('##timeframe').val();" & chr(13) & chr(10);
		sReturn &=	"var ts = $('##scenarios').val();" & chr(13) & chr(10);
		sReturn &=	"reportOptions.TESTSCENARIOS = ts;" & chr(13) & chr(10);
		sReturn &=	"reportAandS.ACCESSBY = $('##AccessBy').val();" & chr(13) & chr(10);
		sReturn &=	"reportAandS.CREATEREPORT = $('##createreport').val();" & chr(13) & chr(10);
		sReturn &=	"reportAandS.EMAIL.NOTIFYME = $('##notifyme:checked').length == 1 ? '"& session.useridint & "' : '0';" & chr(13) & chr(10);
		sReturn &=	"reportAandS.EMAIL.SENDLINKTOUSERIDS = $('##sendlinktouserids').val();" & chr(13) & chr(10);
		sReturn &=  "reportAandS.EMAIL.SENDASATTACHMENTTO = $('##sendasattachmentto').val();" & chr(13) & chr(10);
		sReturn &=	"reportAandS.STARTTIME = $('##starttime').val();" & chr(13) & chr(10);
		return sReturn;
    }
	
	public void function saveReport()
    {
        if ( variables.reportid == 0 ) {
			report = EntityNew("TTestReports");
		} else {
			report = EntityLoadByPK("TTestReports",variables.reportid);
		}
		report.setReportTypeName(this.getReportTypeName());
		report.setReportAuthor(this.getAuthor());
		report.setReportGroup(this.getGroup());
		report.setReportVersion(this.getVersion());
		report.setReportName(this.getReportName());
		report.setReportDescription(this.getReportDescription());
		report.setReportOptions(objFunctions.toWddx(this.GetReportOptions()));
		report.setReportAccessAndScheduling(objFunctions.toWddx(this.getAccessAndScheduling()));
		report.setProjectID(Session.ProjectID);
		EntitySave(report);
		variables.reportid = report.getId();
		if ( variables.AccessAndScheduling.CreateReport != "once" ) {
			objMaintenance = createObject("component","CFTestTrack.cfc.Maintenance");
			objMaintenance.createTask(report.getId(),variables.AccessAndScheduling.CreateReport,variables.AccessAndScheduling.StartDate,variables.AccessAndScheduling.StartTime);
		}
    }

	public any function runReport()
    {
        if ( StructKeyExists(variables.AccessAndScheduling,"CreateReport") && variables.AccessAndScheduling.CreateReport == "Once")
		{
			if ( FileExists("../../reportpdfs/"&variables.reportid&".pdf") ) 
			{
				return;
			}
		}
		
		if ( StructKeyExists(variables.ReportOptions,"TimeFrame") )
		{
			switch(variables.ReportOptions.TimeFrame)
			{
				case "Today":
					datestart = Now();
					dateend = Now();
					break;
				case "Week":
					datestart = Now();
					dateend = DateAdd("d",-7,Now());
					break;
				case "Month":
					datestart = Now();
					dateend = DateAdd("m",-1,Now());
					break;
				case "All":
					datestart = DateAdd("yyyy",-10,now());
					dateend = Now();
					break;
			}	
		}
		objData = createObject("component","CFTestTrack.cfc.Data");
		rs1 = objData.qryTestDefects(variables.ReportOptions.TESTSCENARIOS); //Session.ProjectID,datestart,dateend);
		reportoutput = "<h3>Defect Summary</h3><table class='table table-condensed table-striped'><thead><tr><th>Test Title</th><th>Action</th><th>Date Tested</th><th>Comment</th><th>Defects</th><th>Elapsed Time</th><th>Version</th><th>Tester</th><th>Test Scenario</th></tr></thead><tbody>";
		//for ( q in rs1 ) {
		for ( q = 1; q <= rs1.RecordCount; q++ ) {
			//reportoutput &= "<tr><td><span class='label " & returnBSLabelStyle(rs1.Status[q]) & "'>" & rs1.TestTitle[q] & "</span></td><td>" & rs1.ResultCount[q] & "</td></tr>";
            reportoutput &= "<tr><td>" & rs1.TestTitle[q] & "</td><td>" & rs1.Action[q] & "</td><td>" & rs1.DateTested[q] & "</td><td>" & rs1.Comment[q] & "</td><td>" & rs1.Defects[q] & "</td><td>" & rs1.ElapsedTime[q] & "</td><td>" & rs1.Version[q] & "</td><td>" & rs1.UserName[q] & "</td><td>" & rs1.TestScenario[q] & "</td></tr>";
        }
		
		reportoutput &= "</tbody></table>";
		headeroutput = '<!DOCTYPE html><html lang="en"><head><link rel="stylesheet" type="text/css" media="screen" href="style/bootstrap.css?'&createUUID()&'" /><script type="text/javascript" src="scripts/jquery-1.10.2.min.js?'&createUUID()&'"></script><script type="text/javascript" src="scripts/ChartNew.js?'&createUUID()&'"></script><script type="text/javascript" src="scripts/bootstrap-select.min.js?'&createUUID()&'"></script></head><body><div class="container-fluid" style="background:none;">';
		footeroutput = '</div></body></html>';
		writeOutput(headeroutput & reportoutput & footeroutput); 
		
		pdfvar = objFunctions.createPDFfromContent(reportoutput);
		fileWrite(ExpandPath("/reportpdfs/") & variables.reportid & ".pdf",pdfvar);
		//objFunctions = createObject("component","cfc.Functions");
		if ( variables.AccessAndScheduling.Email.NotifyMe gt 0) {
			arruser = EntityLoadByPK("TTestTester",variables.AccessAndScheduling.Email.NotifyMe);
			emailbody = "<h1>" & variables.ReportName & "</h1><p>Your report is available <a href='https://" & Application.HttpsUrl & "/" & Application.applicationname & "/reportpdfs/" & variables.reportid & ".pdf'>here</a>.</p>";
			objFunctions.MailerFunction(arruser.getEmail(),application.MailerDaemonAddress,variables.ReportName & " Available",emailbody);
		}
		if ( len(variables.AccessAndScheduling.Email.sendlinktouserids) gt 0 && IsValid("email",ListGetat(variables.AccessAndScheduling.Email.sendlinktouserids,1))) {
			
		}
    }
	
	public any function showReport()
    {

    }

}