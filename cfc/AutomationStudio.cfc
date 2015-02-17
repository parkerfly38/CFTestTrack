component extends="cfselenium.CFSeleniumTestCase"
{
	remote any function RunTest(required string sUrl, required string browser, required numeric testid, required numeric testerid) {
		selenium = new cfselenium.selenium();
		selenium.start(arguments.sUrl,arguments.browser);
		
		//load our test case steps
		arrTestSteps = EntityLoad("TASSteps",{TestID=arguments.testid});
		mds = GetMetaData(selenium);
		SESSION.MDS = mds;
		listOfNames = "";
		for (func in mds.FUNCTIONS) {
			if (func.ACCESS == "public" && StructKeyExists(func,"HINT") && Len(func.HINT) > 0) {
				listOfNames = listAppend(listofNames,func.NAME);
			}
		}
		AlphaListOfNames = ListSort(listofNames,"text","asc");
		
		var testresult = EntityNew("TTestResult");
		
		try {
			for (step in arrTestSteps) {
				paramLength = 0;
				if ( step.getAction() CONTAINS "assert" )
				{
					evaluate("#step.getAction()#(#step.getValueOne()#,#step.getValueTwo()#)");
				} else {
					for ( i=1; i <= ListLen(AlphaListOfNames); i++) {
						for ( func in mds.FUNCTIONS) {
							if ( func.NAME == step.getAction() )
							{
								paramLength = ArrayLen(func.PARAMETERS);
							}		
						}
					}
					switch(paramLength) {
						case 0:
							evaluate("selenium.#step.getAction()#()");
							break;
						case 1:
							evaluate("selenium.#step.getAction()#('#step.getValueOne()#')");
							break;
						case 2:
							evaluate("selenium.#step.getAction()#('#step.getValueOne()#','#step.getValueTwo()#')");
							break;
					}
				}
				
				
			} 
		} 
		catch (any e)
		{
			StatusObj = EntityLoadByPk("TTestStatus",3);
			testresult.setTTestStatus(StatusObj);
			TesterObj = EntityLoadByPk("TTestTester",arguments.testerid);
			testresult.setTTestTester(TesterObj);
			testresult.setVersion("1");
			testresult.setElapsedTime("1");
			testresult.setComment(e.Message);
			testresult.setAttachmentList("");
			testresult.setDefects("");
			testresult.setDateTested(Now());
			testresult.setTestCaseID(arguments.testid);
			EntitySave(testresult);
			rethrow;
		}
		finally {
			selenium.stop();
		}
		StatusObj = EntityLoadByPk("TTestStatus",2);
		testresult.setTTestStatus(StatusObj);
		TesterObj = EntityLoadByPk("TTestTester",arguments.testerid);
		testresult.setTTestTester(TesterObj);
		testresult.setVersion("1");
		testresult.setElapsedTime("1");
		testresult.setComment("Passed");
		testresult.setAttachmentList("");
		testresult.setDefects("");
		testresult.setDateTested(Now());
		testresult.setTestCaseID(arguments.testid);
		EntitySave(testresult);
	}
	
	remote any function getSpecificMeta(required string funcName) returnformat="JSON" output="false" {
		structMetaData = StructNew();
		switch (arguments.funcname) {
			case "assertTrue":case "assertFalse":
				structMetaData.Hint = "If this assertion fails, it will throw an exception and fail your test.  The first parameter will be the condition that will pass/fail if it is true/false, the second is the message you want recorded about this failure.";
				structMetaData.params = [];
				structMetaData.params[1] = StructNew();
				structMetaData.params[1].NAME = 'boolean condition';
				structMetaData.params[1].REQUIRED = 'true';
				structMetaData.params[1].TYPE = 'expression/boolean function';
				structMetaData.params[2] = StructNew();
				structMetaData.params[2].NAME = 'message string';
				structMetaData.params[2].REQUIRED = 'true';
				structMetaData.params[2].TYPE = 'string';
				return serializeJSON(structMetaData);
				break;
			case "assertEquals":
				structMetaData.Hint = "Compare the expected value with the actual value to determine if the test passes or fails.  The message will be what is recorded as a failure.";
				structMetaData.params = [];
				structMetaData.params[1] = StructNew();
				structMetaData.params[1].NAME = 'expected value';
				structMetaData.params[1].REQUIRED = 'true';
				structMetaData.params[1].TYPE = 'string/number';
				structMetaData.params[2] = StructNew();
				structMetaData.params[2].NAME = 'actual value';
				structMetaData.params[2].REQUIRED = 'true';
				structMetaData.params[2].TYPE = 'Expression';
				structMetaData.params[3] = StructNew();
				structMetaData.params[3].NAME = 'message string';
				structMetaData.params[3].REQUIRED = 'true';
				structMetaData.params[3].TYPE = 'string';
				return serializeJSON(structMetaData);
				break;
			case "failNotEquals":
				structMetaData.Hint = "Used to fail when two values do not equal. This doesn't perform any assertion... it's simply a convenience method for providing a specific type of failure message.";
				structMetaData.params = [];
				structMetaData.params[1] = StructNew();
				structMetaData.params[1].NAME = 'expected value';
				structMetaData.params[1].REQUIRED = 'true';
				structMetaData.params[1].TYPE = 'string/number';
				structMetaData.params[2] = StructNew();
				structMetaData.params[2].NAME = 'actual value';
				structMetaData.params[2].REQUIRED = 'true';
				structMetaData.params[2].TYPE = 'Expression';
				structMetaData.params[3] = StructNew();
				structMetaData.params[3].NAME = 'message string';
				structMetaData.params[3].REQUIRED = 'true';
				structMetaData.params[3].TYPE = 'string';
				return serializeJSON(structMetaData);
				break;
		}
		if ( StructKeyExists(SESSION,"MDS") ) {
			for ( func in SESSION.MDS.FUNCTIONS) {
				if ( func.NAME == arguments.funcName ) {
					if ( len(func.HINT) > 0 ) { 
						structMetaData.Hint = func.HINT;
					} else {
						structMetaData.Hint = "";
					}
					structMetaData.params = func.PARAMETERS;
				}
			}
			return serializeJSON(structMetaData);
		} else {
			return serializeJSON(structMetaData);
		}
	}
	
	remote any function appendAutomationArray(required numeric testcaseid, required string action, string valueone="", string valuetwo="", string valuethree="", string valuefour="", string assertionmessage="", required numeric orderofoperation) {
		if ( !StructKeyExists(SESSION,"AutomationArray") ) {
			SESSION.AutomationArray = [];
		}
		tempstruct = StructNew();
		tempstruct.automationid = 0;
		tempstruct.testcaseid = arguments.testcaseid;
		tempstruct.action = arguments.action;
		tempstruct.valueone = arguments.valueone;
		tempstruct.valuetwo = arguments.valuetwo;
		tempstruct.valuethree = arguments.valuethree;
		tempstruct.valuefour = arguments.valuefour;
		tempstruct.assertionmessage = arguments.assertionmessage;
		tempstruct.orderofoperation = arguments.orderofoperation;
		ArrayAppend(SESSION.AutomationArray, tempstruct);
		loadTempTable();
	}
	
	remote any function loadAutomationArray(required numeric testcaseid) {
		Session.AutomationArray = [];
		arrAutomationArray = EntityLoad("TASSteps",{TestID = arguments.testcaseid},"OrderOfOperation Asc");
		if ( ArrayLen(arrAutomationArray) > 0 ) {
			for (automate in arrAutomationArray) {
				tempStruct = StructNew();
				tempStruct.automationid = automate.getId();
				tempStruct.testcaseid = automate.getTestID();
				tempStruct.action = automate.getAction();
				tempStruct.valueone = isNull(automate.getValueOne()) ? "" : automate.getValueOne();
				tempStruct.valuetwo = isNull(automate.getValueTwo()) ? "" : automate.getValueTwo();
				tempStruct.valuethree = isNull(automate.getValueThree()) ? "" : automate.getValueThree();
				tempStruct.valuefour = isnull(automate.getValueFour()) ? "" : automate.getValueFour();
				tempStruct.assertionmessage = isnull(automate.getAssertionMessage()) ? "" : automate.getAssertionMessage();
				tempStruct.orderofoperation = automate.getOrderOfOperation();
				ArrayAppend(SESSION.AutomationArray,tempstruct);
			}
		}
		loadTempTable();
	}
	
	remote string function loadTempTable() output="true" {
		if ( StructKeyExists(Session,"AutomationArray") ) {
			writeOutput("<table id='automationtable' class='table table-condensed table-striped table-hover'>");
			writeOutput("<thead><tr>");
			writeOutput("<th>Action</th><th>Param 1</th><th>Param 2</th><th>Param 3</th><th>Param 4</th><th>Assertion Message</th><th>Order</th>");
			writeOutput("</tr></thead>");
			writeOutput("<tbody>");
			var x = arraylen(Session.AutomationArray);
			for (i=1;i <= x;  i++)
			{
				writeOutput("<tr><td><input type='hidden' class='automationid' value='"& Session.AutomationArray[i].AUTOMATIONID & "' /><input type='hidden' class='testid' value='" & Session.AutomationArray[i].TESTCASEID & "' />");
				writeOutput("<input type='hidden' class='action' value='" & Session.AutomationArray[i].ACTION & "' disabled />" & Session.AutomationArray[i].ACTION & "</td>");
				writeOutput("<td><input type='text' class='valueone' value='" & Session.AutomationArray[i].VALUEONE & "' /></td>");
				writeOutput("<td><input type='text' class='valuetwo' value='" & Session.AutomationArray[i].VALUETWO & "' /></td>");
				writeOutput("<td><input type='text' class='valuethree' value='" & Session.AutomationArray[i].VALUETHREE & "' /></td>");
				writeOutput("<td><input type='text' class='valuefour' value='" & Session.AutomationArray[i].VALUEFOUR & "' /></td>");
				writeOutput("<td><input type='text' class='assertionmessage' value='" & Session.AutomationArray[i].ASSERTIONMESSAGE & "' /></td>");
				writeOutput("<td><input type='text' class='orderofoperation' size='3' value='" & Session.AutomationArray[i].ORDEROFOPERATION & "' /></td></tr>");
			}
			writeOutput("</tbody></table>");
		}
	}
	
	remote any function saveRow(numeric automationid, numeric testid, string action, string valueone="", string valuetwo="", string valuethree="", string valuefour="", string assertionmessage="", numeric orderofoperation) {
		if ( automationid > 0 ) {
			arrNewRow = EntityLoadByPK("TASSteps",arguments.automationid);
		} else {
			arrNewRow = EntityNew("TASSteps");
		}
		arrNewRow.setTestId(arguments.testid);
		arrNewRow.setAction(arguments.action);
		arrNewRow.setValueOne(arguments.valueone);
		arrNewRow.setValueTwo(arguments.valuetwo);
		arrNewRow.setValueThree(arguments.valuethree);
		arrNewRow.setValueFour(arguments.valuefour);
		arrNewRow.setAssertionMessage(arguments.assertionmessage);
		arrNewRow.setOrderOfOperation(arguments.orderofoperation);
		EntitySave(arrNewRow);
	}
	
	remote string function GetListObj() output="true" {
		StructDelete(SESSION,"AutomationArray");
		selenium = new cfselenium.selenium();
		mds = GetMetaData(selenium);
		SESSION.MDS = mds;
		listOfNames = "";
		writeOutput("<script type='text/javascript'>" & chr(13));
		writeOutput("$(document).ready(function() {" & chr(13));
		writeOutput('	$(".selectpicker").selectpicker();' & chr(13));
		writeOutput('   $(document).off("click","##btnSave");' & chr(13));
		writeOutput("	$(document).on('click','##btnSave',function(event) {" & chr(13));
		writeOutput("		$('##automationtable > tbody > tr').each(function() {" & chr(13));
		writeOutput("			var automationid = $(this).find('.automationid').val();" & chr(13));
		writeOutput("			var testid = $(this).find('.testid').val();" & chr(13));
		writeOutput("			var action = $(this).find('.action').val();" & chr(13));
		writeOutput("			var valueone = $(this).find('.valueone').val();" & chr(13));
		writeOutput("			var valuetwo = $(this).find('.valuetwo').val();" & chr(13));
		writeOutput("			var valuethree = $(this).find('.valuethree').val();" & chr(13));
		writeOutput("			var valuefour = $(this).find('.valuefour').val();" & chr(13));
		writeOutput("			var assertionmessage = $(this).find('.assertionmessage').val();" & chr(13));
		writeOutput("			var orderofoperation = $(this).find('.orderofoperation').val();" & chr(13));
		writeOutput("			$.ajax({url:'CFC/AutomationStudio.cfc?method=saveRow',type:'POST',data: { automationid : automationid, testid : testid, action : action, valueone : valueone, valuetwo : valuetwo, valuethree : valuethree, valuefour : valuefour, assertionmessage : assertionmessage, orderofoperation : orderofoperation }});"&chr(13));
		writeOutput("	 	});"&chr(13));
		writeOutput("		$('##largeModal').modal('hide');" & chr(13));
		writeOutput("	});"&chr(13));
		writeOutput("	$(document).off('change','##ddlTestCase');" & chr(13));
		writeOutput("	$(document).on('change','##ddlTestCase',function() {" & chr(13));
   		writeOutput("			$.ajax({ url: 'cfc/AutomationStudio.cfc?method=loadAutomationArray',type:'POST',data: { testcaseid : $(this).val() }}).done( function(data) { $('##actiontable').html(data); });" & chr(13));
   		writeOutput("	});" & chr(13));
   		writeOutput("	$(document).off('click','##btnAddTestStep');" & chr(13));
   		writeOutput("	$(document).on('click','##btnAddTestStep',function(event) { "& chr(13));
   		writeOutput("		$.ajax({ url: 'cfc/AutomationStudio.cfc?method=appendAutomationArray',type:'POST',data : { testcaseid : $('##ddlTestCase').val(), action : $('##ddlTAction').val(), valueone : $('##txtValueOne').val(), valuetwo : $('##txtValueTwo').val(), valuethree : $('##txtValueThree').val(), valuefour : $('##txtValueFour').val(), assertionmessage : $('##txtAssertionMessage').val(), orderofoperation : $('##txtOrderofOperations').val()}}).done(function(data) { " & chr(13));
   		writeOutput("			$('##txtValueOne').attr('disabled','disabled');" & chr(13));
   		writeOutput("			$('##txtValueTwo').attr('disabled','disabled');" & chr(13));
   		writeOutput("			$('##txtValueThree').attr('disabled','disabled');" & chr(13));
   		writeOutput("			$('##txtValueFour').attr('disabled','disabled');" & chr(13));
   		writeOutput("			$('##txtValueOne').removeAttr('placeholder');" & chr(13));
   		writeOutput("			$('##txtValueTwo').removeAttr('placeholder');" & chr(13));
   		writeOutput("			$('##txtValueThree').removeAttr('placeholder');" & chr(13));
   		writeOutput("			$('##txtValueFour').removeAttr('placeholder');" & chr(13));
   		writeOutput("			$('##ddlTAction').prop('selectedIndex',-1);" & chr(13));
   		writeOutput("			$('##txtValueOne,##txtValueTwo,##txtValueThree,##txtValueFour,##txtAssertionMessage').val('');" & chr(13));
   		writeOutput("			$('##actiontable').html(data);" & chr(13));
   		writeOutput("		}); });"&chr(13));
   		writeOutput("	$(document).off('change','##ddlTAction');" & chr(13));
   		writeOutput("	$(document).on('change','##ddlTAction',function() { " & chr(13));
   		writeOutput("		var funcname = $(this).val();" & chr(13));
   		writeOutput("		$.getJSON('cfc/AutomationStudio.cfc?method=getSpecificMeta&funcName='+funcname,function(data) {" & chr(13));
   		writeOutput("			$('##pnlDesc .panel-heading').text(funcname);" & chr(13));
   		writeOutput("			$('##pnlDesc .panel-body').html(data.HINT);" & chr(13));
   		writeOutput("			if ( data.PARAMS.length == 1 ) {" & chr(13));
   		writeOutput("				$('##txtValueOne').removeAttr('disabled');" & chr(13));
   		writeOutput("				$('##txtValueOne').attr('placeholder','NAME: '+data.PARAMS[0].NAME+', TYPE: '+data.PARAMS[0].TYPE+', REQUIRED: '+data.PARAMS[0].REQUIRED);" & chr(13));
   		writeOutput("				$('##txtValueTwo').attr('disabled','disabled');" & chr(13));
   		writeOutput("				$('##txtValueTwo').removeAttr('placeholder');" & chr(13));
   		writeOutput("				$('##txtValueThree').attr('disabled','disabled');" & chr(13));
   		writeOutput("				$('##txtValueThree').removeAttr('placeholder');" & chr(13));
   		writeOutput("				$('##txtValueFour').attr('disabled','disabled');" & chr(13));
   		writeOutput("				$('##txtValueFour').removeAttr('placeholder');" & chr(13));
   		writeOutput("			}" & chr(13));
   		writeOutput("			if ( data.PARAMS.length == 2 ) {" & chr(13));
   		writeOutput("				$('##txtValueOne').removeAttr('disabled');" & chr(13));
   		writeOutput("				$('##txtValueTwo').removeAttr('disabled');" & chr(13));
   		writeOutput("				$('##txtValueOne').attr('placeholder','NAME: '+data.PARAMS[0].NAME+', TYPE: '+data.PARAMS[0].TYPE+', REQUIRED: '+data.PARAMS[0].REQUIRED);" & chr(13));
   		writeOutput("				$('##txtValueTwo').attr('placeholder','NAME: '+data.PARAMS[1].NAME+', TYPE: '+data.PARAMS[1].TYPE+', REQUIRED: '+data.PARAMS[1].REQUIRED);" & chr(13));
   		writeOutput("				$('##txtValueThree').attr('disabled','disabled');" & chr(13));
   		writeOutput("				$('##txtValueThree').removeAttr('placeholder');" & chr(13));
   		writeOutput("				$('##txtValueFour').attr('disabled','disabled');" & chr(13));
   		writeOutput("				$('##txtValueFour').removeAttr('placeholder');" & chr(13));
   		writeOutput("			}" & chr(13));
   		writeOutput("			if ( data.PARAMS.length == 3 ) {" & chr(13));
   		writeOutput("				$('##txtValueOne').removeAttr('disabled');" & chr(13));
   		writeOutput("				$('##txtValueTwo').removeAttr('disabled');" & chr(13));
   		writeOutput("				$('##txtValueThree').removeAttr('disabled');" & chr(13));
   		writeOutput("				$('##txtValueOne').attr('placeholder','NAME: '+data.PARAMS[0].NAME+', TYPE: '+data.PARAMS[0].TYPE+', REQUIRED: '+data.PARAMS[0].REQUIRED);" & chr(13));
   		writeOutput("				$('##txtValueTwo').attr('placeholder','NAME: '+data.PARAMS[1].NAME+', TYPE: '+data.PARAMS[1].TYPE+', REQUIRED: '+data.PARAMS[1].REQUIRED);" & chr(13));
   		writeOutput("				$('##txtValueThree').attr('placeholder','NAME: '+data.PARAMS[2].NAME+', TYPE: '+data.PARAMS[2].TYPE+', REQUIRED: '+data.PARAMS[2].REQUIRED);" & chr(13));
   		writeOutput("				$('##txtValueFour').attr('disabled','disabled');" & chr(13));
   		writeOutput("				$('##txtValueFour').removeAttr('placeholder');" & chr(13));
   		writeOutput("			}");
   		writeOutput("			if ( data.PARAMS.length >= 4 ) {" & chr(13));
   		writeOutput("				$('##txtValueOne').removeAttr('disabled');" & chr(13));
   		writeOutput("				$('##txtValueTwo').removeAttr('disabled');" & chr(13));
   		writeOutput("				$('##txtValueThree').removeAttr('disabled');" & chr(13));
   		writeOutput("				$('##txtValueFour').removeAttr('disabled');" & chr(13));
   		writeOutput("				$('##txtValueOne').attr('placeholder','NAME: '+data.PARAMS[0].NAME+', TYPE: '+data.PARAMS[0].TYPE+', REQUIRED: '+data.PARAMS[0].REQUIRED);" & chr(13));
   		writeOutput("				$('##txtValueTwo').attr('placeholder','NAME: '+data.PARAMS[1].NAME+', TYPE: '+data.PARAMS[1].TYPE+', REQUIRED: '+data.PARAMS[1].REQUIRED);" & chr(13));
   		writeOutput("				$('##txtValueThree').attr('placeholder','NAME: '+data.PARAMS[2].NAME+', TYPE: '+data.PARAMS[2].TYPE+', REQUIRED: '+data.PARAMS[2].REQUIRED);" & chr(13));
   		writeOutput("				$('##txtValueFour').attr('placeholder','NAME: '+data.PARAMS[3].NAME+', TYPE: '+data.PARAMS[3].TYPE+', REQUIRED: '+data.PARAMS[3].REQUIRED);" & chr(13));
   		writeOutput("			}" & chr(13));
   		writeOutput("			if ( data.PARAMS.length == 0 ) {" & chr(13));
   		writeOutput("				$('##txtValueOne').attr('disabled','disabled');" & chr(13));
   		writeOutput("				$('##txtValueTwo').attr('disabled','disabled');" & chr(13));
   		writeOutput("				$('##txtValueThree').attr('disabled','disabled');" & chr(13));
   		writeOutput("				$('##txtValueFour').attr('disabled','disabled');" & chr(13));
   		writeOutput("				$('##txtValueOne').removeAttr('placeholder');" & chr(13));
   		writeOutput("				$('##txtValueTwo').removeAttr('placeholder');" & chr(13));
   		writeOutput("				$('##txtValueThree').removeAttr('placeholder');" & chr(13));
   		writeOutput("				$('##txtValueFour').removeAttr('placeholder');" & chr(13));
   		writeOutput("			}" & chr(13));
   		writeOutput("		});" & chr(13));
        writeOutput("	});" & chr(13));
        writeOutput('});' & chr(13));
		writeOutput("</script>" & chr(13));
		
		//load test cases by those set to automated and session id
		arrTestCases = EntityLoad("TTestCase",{TypeId = 4, ProjectID = Session.ProjectID});
		if ( ArrayLen(arrTestCases) == 0 ) {
			writeOutput("<div class='alert alert-danger'><strong>There are no automated test cases created for this project.</strong></div>");
		} else {
			writeOutput("<div class='alert alert-warning'><strong>Select a test case:</strong><br /><select class='form-control selectpicker' id='ddlTestCase' name='ddlTestCase' data-style='btn-info'>");
			writeOutput("<option> --- </option>");
			for (tc in arrTestCases) {
				writeOutput("<option value='" & tc.getId() & "'>TC"& tc.getId() & " - " & tc.getTestTitle() & "</option>");
			}
			writeOutput("</select></div>");
		}
		
		writeOutput("<p>Build an automated test case by selecting actions and setting their parameters below.  For <em>locator</em> parameters, remember you can use css classes (css=reference), ids (id=reference), names (name=), and complex XPath logic to get at the web piece you want.  See the wiki for more thorough documentation.</p>");
		writeOutput("<div class='col-xs-4 col-sm-4 col-md-4 col-lg-4'>");
		
		writeOutput("<select id='ddlTAction' class='form-control' size='8' style='height:150px;'>");
		writeOutput("<optgroup label='MXUnit Assertions'><option value='assertTrue'>assertTrue</option><option value='assertFalse'>assertFalse</option><option value='assertEquals'>assertEquals</option><option value='failNotEquals'>failNotEquals</option><optgroup>");
		for (func in mds.FUNCTIONS) {
			if (func.ACCESS == "public" && StructKeyExists(func,"HINT") && Len(func.HINT) > 0) {
				listOfNames = listAppend(listofNames,func.NAME);
			}
		}
		writeOutput("<optgroup label='Selenium Options'>");
		AlphaListOfNames = ListSort(listofNames,"text","asc");
		for ( i=1; i <= ListLen(AlphaListOfNames); i++) {
			for ( func in mds.FUNCTIONS) {
				if (func.NAME == ListGetAt(AlphaListOfNames,i) ) {
					writeOutput("<option data-toggle='popover' data-placement='bottom' data-trigger='hover' data-content='");
					if (ArrayLen(func.PARAMETERS) > 0) {
						writeOutput("Parameters: ");
						for (param in func.PARAMETERS ) {
							writeOutput("  " & param.NAME & ", required=" & param.REQUIRED & ", type=" & param.TYPE & ";");
						}
					}
					writeOutput("'>"&func.NAME&"</option>");
				}
			}
		}
		writeOutput("</optgroup></select><br /><div id='pnlDesc' class='panel panel-primary'><div class='panel-heading'>Selenium and MXUnit Test Options</div><div class='panel-body' style='height:200px;overflow:auto;'>Select an action to the left for a description and parameter requirements.</div></div></div>");
		writeOutput("<div class='col-xs-8 col-sm-8 col-md-8 col-lg-8'><label for='txtValueOne'>First Parameter Value</label><br /><input type='text' id='txtValueOne' class='form-control' disabled /><label for='txtValueTwo'>Second Parameter Value</label><br /><input type='text' id='txtValueTwo' class='form-control' disabled  /><label for='txtValueThree'>Third Parameter Value</label><br /><input type='text' id='txtValueThree' class='form-control' disabled /><label for='txtValueFour'>Fourth Parameter Value</label><br /><input type='text' id='txtValueFour' class='form-control' disabled /><label for='txtAssertionMessage' style='display: none;'>Assertion Failure Message</label><br /><input type='text' id='txtAssertionMessage' class='form-control' disabled style='display:none;' /><label for='txtOrderofOperations'>Order Number</label><br /><input type='text' id='txtOrderofOperations' class='form-control' /><br /><button id='btnAddTestStep' class='btn btn-success'><i class='fa fa-plus-circle'></i> Add Test Step</button></div><div id='actiontable' class='col-xs-12 col-sm-12 col-md-12 col-lg-12'>");
		loadTempTable();
		writeOutput("</div>");
	}
}