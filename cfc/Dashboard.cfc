<cfcomponent>
	
	<cfset objFunctions = createObject("component","Functions")>
	<cfset objData = createObject("component","Data")>
	
	<cffunction name="listAxoSoftItems" access="public" output="true">
		<cfargument name="axosoftItems" type="struct">
		<cfargument name="projectid" type="numeric" default="0" required="true">
		<cfargument name="ppaging" type="numeric" default="1">
		<cfargument name="bpaging" type="numeric" default="1">
		<div id="panelaxosoftitems" class="panel panel-default">
			<div class="panel-heading"><i class="fa fa-tasks"></i> Items</div>
			<div class="panel-body">
			<cfif StructKeyExists(arguments.axosoftitems,"error") || !Application.AxoSoftUseAPI>
				<ul class="nav nav-tabs">
					<li<cfif arguments.ppaging gte 1 and arguments.bpaging eq 0> class="active"</cfif>><a href="##incidents" data-toggle="tab">Incidents</a></li>
					<li<cfif arguments.bpaging gte 1 and arguments.ppaging eq 0> class="active"</cfif>><a href="##bugs" data-toggle="tab">Bugs</a><li>
				</ul>
				<div class="tab-content">
					<div id="incidents" class="tab-pane fade<cfif arguments.ppaging gte 1 and arguments.bpaging eq 0> in active</cfif>">
						<cfquery name="qryIncidents">
							SELECT id, ProjectTitle, AxoSoftID FROM TTestProject
							WHERE AxoSoftID LIKE 'COG%'
							<cfif arguments.projectid neq 0>
							AND AxoSoftProjectID = #arguments.projectid#
							</cfif>
							ORDER BY AxoSoftID
						</cfquery>
						<cfif qryIncidents.RecordCount gt 0>
							<cfset totalPages = ceiling(qryIncidents.RecordCount/20)>
							<cfset thisPage = ceiling(arguments.ppaging/20)>
							<nav>
								<ul class="pagination pagination-sm">
									
									<li<cfif arguments.ppaging eq 1> class="disabled"</cfif>><a href="?ppage=#arguments.ppaging - 1#" aria-label="Previous"><span aria-hidden="true">&laquo;</span></a></li>
									<cfloop from="1" to="#totalPages#" index="page">
										<li<cfif page eq arguments.ppaging> class="active"</cfif>><a href="?ppage=#page#">#page#</a></li>
									</cfloop>
									
									<li<cfif arguments.ppaging gte totalPages> class="disabled"</cfif>><a href="?ppage=#arguments.ppaging + 1#" aria-label="Next"><span aria-hidden="true">&raquo;</span></a></li>
								</ul>
							</nav>
							<table class="table table-condensed table-striped">
								<cfif arguments.ppaging eq 0>
									<cfset ppage = 1>
								<cfelse>
									<cfset ppage = arguments.ppaging>
								</cfif>
								<cfloop query="qryIncidents" startrow="#((ppage-1)*20)+1#" endrow="#((ppage)*20)#">
									<tr>
										<td colspan="2"><a href="http://#Application.HttpsUrl#/CFTestTrack/item/#id#/">#AxoSoftID#</a></td>
										<td>#ProjectTitle#</td>
									</tr>
								</cfloop>
							</table>
						<cfelse>
							<div class="alert alert-warning"><h2>There are no AxoSoft incidents for this project.</h2></div>
						</cfif>
					</div>
					<div id="bugs" class="tab-pane fade<cfif arguments.bpaging gte 1 and arguments.ppaging eq 0> in active</cfif>">
						<cfquery name="qryBugs">
							SELECT id, ProjectTitle,AxoSoftID FROM TTestProject
							WHERE AxoSoftID NOT LIKE 'COG%' and AxoSoftID IS NOT NULL
							<cfif arguments.projectid neq 0>
							AND AxoSoftProjectID = #arguments.projectid#
							</cfif>
							ORDER BY AxoSoftID
						</cfquery>
						<cfif qryBugs.RecordCount gt 0>
							<cfset btotalPages = ceiling(qryBugs.RecordCount/20)>
							<cfset bthisPage = ceiling(arguments.bpaging/20)>
							<nav>
								<ul class="pagination pagination-sm">
									
									<li<cfif arguments.bpaging eq 1> class="disabled"</cfif>><a href="?bpage=#arguments.bpaging - 1#" aria-label="Previous"><span aria-hidden="true">&laquo;</span></a></li>
									<cfloop from="1" to="#btotalPages#" index="page">
										<li<cfif page eq arguments.bpaging> class="active"</cfif>><a href="?bpage=#page#">#page#</a></li>
									</cfloop>
									
									<li<cfif arguments.bpaging gte btotalPages> class="disabled"</cfif>><a href="?bpage=#arguments.bpaging + 1#" aria-label="Next"><span aria-hidden="true">&raquo;</span></a></li>
								</ul>
							</nav>
							<table class="table table-condensed table-striped">
								<cfif arguments.bpaging eq 0>
									<cfset bpage = 1>
								<cfelse>
									<cfset bpage = arguments.bpaging>
								</cfif>
								<cfloop query="qryBugs" startrow="#((bpage-1)*20)+1#" endrow="#((bpage)*20)#">
									<tr>
										<td colspan="2"><a href="http://#Application.HttpsUrl#/CFTestTrack/item/#id#/">#AxoSoftID#</a></td>
										<td>#ProjectTitle#</td>
									</tr>
								</cfloop>
							</table>
						<cfelse>
							<div class="alert alert-warning"><h2>There are no AxoSoft bugs for this project.</h2></div>
						</cfif>
					</div>
				</div>
			<cfelse>
				<ul class="nav nav-tabs">
					<li class="active"><a href="##incidents" data-toggle="tab">Incidents</a></li>
					<li><a href="##bugs" data-toggle="tab">Bugs</a><li>
				</ul>
				<div class="tab-content">
					<div id="incidents" class="tab-pane fade in active">
						<table class="table table-condensed table-striped">
						<cfloop array="#arguments.axosoftItems["data"]#" index="i">
							<cfif i.number CONTAINS "COG">
							<cfscript>
								if ( ArrayLen(EntityLoad("TTestProject",{AxoSoftID = i.number})) lte 0 ) {
									newTestProject = new CFTestTrack.cfc.db.TTestProject();
								 	newTestProject.setProjectTitle(i.name);
								 	newTestProject.setAxoSoftID(i.number);
								 	newTestProject.setProjectDescription(i.description);
								 	newTestProject.setProjectStartDate(isnull(i.start_date) || i.start_date == "null" ? DateFormat(ParseDateTime(left(i.created_date_time,10),"yyyy-MM-dd"),"mm/dd/yyyy")  : DateFormat(ParseDateTime(left(i.start_date,10),"yyyy-MM-dd"),"mm/dd/yyyy"));
								 	newTestProject.setIncludeAnnouncement(false);
								 	newTestProject.setRepositoryType(1);
								 	newTestProject.setClosed(0);
								 	newTestProject.setAxoSoftProjectID(i.project.id);
								 	newTestProject.setAxoSoftSystemID(i.id);
								 	EntitySave(newTestProject);
								 }							
							</cfscript>
							<tr>
								<td colspan="2"><a href="http://#Application.HttpsUrl#/CFTestTrack/item/#i.id#/">#i.number#</a></td>
								<td>#i.name#</td>
							</tr>
							</cfif>
						</cfloop>
						</table></div>
					<div id="bugs" class="tab-pane fade">
					<table class="table table-condensed table-striped">
						<cfloop array="#arguments.axosoftItems["data"]#" index="i">
							<cfif i.number DOES NOT CONTAIN "COG">
							<cfscript>
								if ( ArrayLen(EntityLoad("TTestProject",{AxoSoftID = i.number})) lte 0 ) {
									newTestProject = new CFTestTrack.cfc.db.TTestProject();
								 	newTestProject.setProjectTitle(i.name);
								 	newTestProject.setAxoSoftID(i.number);
								 	newTestProject.setProjectDescription(i.description);
								 	newTestProject.setProjectStartDate(
								 		isnull(i.start_date) || i.start_date == "null" ? DateFormat(ParseDateTime(left(i.created_date_time,10),"yyyy-MM-dd"),"mm/dd/yyyy")  :
								 		DateFormat(ParseDateTime(left(i.start_date,10),"yyyy-MM-dd"),"mm/dd/yyyy"));
								 	newTestProject.setIncludeAnnouncement(false);
								 	newTestProject.setRepositoryType(1);
								 	newTestProject.setClosed(0);
								 	newTestProject.setAxoSoftProjectID(i.project.id);
								 	newTestProject.setAxoSoftSystemID(i.id);
								 	EntitySave(newTestProject);
								 }							
							</cfscript>
							<tr>
								<td colspan="2"><a href="http://#Application.HttpsUrl#/CFTestTrack/item/#i.id#/">#i.number#</a></td>
								<td>#i.name#</td>
							</tr>
							</cfif>
						</cfloop>
						</table></div>
					</div>
			</cfif>
			</div>
		</div>
	</cffunction>
	
	<cffunction name="listProjects" access="public" output="true">
				<cfset objData = new CFTestTrack.cfc.Data()>
				<cfset arrProjects = objData.getAllProjects()>
				<li>
	                <a href="##"><i class="fa fa-wrench fa-fw"></i> Projects<span class="fa arrow"></span></a>
	                <ul class="nav nav-second-level">
	                    <li>
	                        <a href="http://#Application.HttpsUrl#/CFTestTrack/project/add/"><i class="fa fa-plus-circle"></i> Add Project</a>
	                    </li>
	                    <cfif ArrayLen(arrProjects) gt 0>
						<cfloop array="#arrProjects#" index="i">
						<li>							
							<div style="right:5px;bottom:10px;position:absolute; z-index:2;"><a class="btn btn-xs btn-default" href="/CFTestTrack/project/#i.getId()#&edit=true/" style="padding-left:5px;" ><i class="fa fa-pencil"> </i></a>
							<button class="btn btn-xs btn-danger lnkDeleteProject" projectid="#i.getId()#"><i class="fa fa-trash"> </i></button></div>
							<a href="http://#Application.HttpsUrl#/CFTestTrack/project/#i.getId()#/">#i.getProjectTitle()#</a>
							
						</li>
						</cfloop>
						</cfif>
	                </ul>
                            <!-- /.nav-second-level -->
                </li>
	</cffunction>					
	
	<cffunction name="listAxoSoftProjects" access="public" output="true">
		<cfargument name="axosoftprojects" type="struct">
				<cfif StructKeyExists(arguments.axosoftprojects,"error") or !Application.AxoSoftUseAPI>
					<!--- pull from database record instead --->
					<cfquery name="qryProjects">
						SELECT AxoSoftPId, Name, ParentId
						FROM TTestAxoSoftProject
					</cfquery>
					<li>
	                <a href="##"><i class="fa fa-wrench fa-fw"></i> Projects<span class="fa arrow"></span></a>
	                <ul class="nav nav-second-level">
	                    <li>
							<a href="http://#Application.HttpsUrl#/CFTestTrack/project/add/"><i class="fa fa-plus-circle"></i> Add Project</a>
						</li>
						<cfloop query="qryProjects">
						<li>
							<a href="http://#Application.HttpsUrl#/CFTestTrack/project/#AxoSoftPid#/">#Name#</a>
						
						<cfquery name="qryChildren" dbtype="query">
							SELECT AxoSoftPId, Name, ParentId
							FROM qryProjects
							WHERE ParentId = #AxoSoftPId#
						</cfquery>
						<cfif qryChildren.RecordCount gt 0>
						<ul class="nav nav-third-level">
						<cfloop query="qryChildren">
							<li>
								<a href="http://#Application.HttpsUrl#/CFTestTrack/project/#qryChildren.AxoSoftPId#/">#qryChildren.Name#</a>
							</li>
						</cfloop>
						</ul>
						</cfif>
						</cfloop>
						</li>
					</li>					
				<cfelse>
				<li>
					<a href="##"><i class="fa fa-wrench fa-fw"></i> Projects<span class="fa arrow"></span></a>
	                <ul class="nav nav-second-level">					
					<cfloop array="#arguments.axosoftprojects["data"]#" index="i">
					<!--- check and see if it's not new and in the table --->
					<cfscript>
						if ( ArrayLen(EntityLoad("TTestAxoSoftProject",{AxoSoftPId = i.id})) lte 0 ) {
							newAxoSoftProject = new CFTestTrack.cfc.db.TTestAxoSoftProject();
						 	newAxoSoftProject.setAxoSoftPId(i.id);
						 	newAxoSoftProject.setName(i.name);
						 	EntitySave(newAxoSoftProject);
						 }							
					</cfscript>
					<li>
						<a href="http://#Application.HttpsUrl#/CFTestTrack/project/#i.id#/">#i.name#</a>
					<cfif StructKeyExists(i,"children")>
						<ul class="nav nav-third-level">
					<cfloop array="#i.children#" index="c">
						<cfscript>
						if ( ArrayLen(EntityLoad("TTestAxoSoftProject",{AxoSoftPId = c.id})) lte 0) {
							newAxoSoftProject = new CFTestTrack.cfc.db.TTestAxoSoftProject();
						 	newAxoSoftProject.setAxoSoftPId(c.id);
						 	newAxoSoftProject.setName(c.name);
						 	newAxoSoftProject.setParentId(i.id);
						 	EntitySave(newAxoSoftProject);
						 }	else {
						 	arrChild = EntityLoad("TTestAxoSoftProject", {AxoSoftPId = c.id }, true);
						 	if ( arrChild.getParentId() != i.id ) {
						 		arrChild.setParentId(i.id);
						 		EntitySave(arrChild);
						 	}
						 }
						</cfscript>
					<li>
						<a href="http://#Application.HttpsUrl#/CFTestTrack/project/#c.id#/">#c.name#</a>
					</li>
					</cfloop>
					</ul>
					</cfif>
					</li>
					
				</cfloop>
				</ul>
				</li>
				</cfif>
	</cffunction>
	
	<cffunction name="listTestScenarios" access="remote" output="true">
		<cfargument name="projectid" required="true">
		<cfquery name="qryTestScenarios" dbtype="hql" ormoptions=#{maxresults=5}#>
			FROM TTestScenario
			WHERE ProjectID = <cfqueryparam value="#arguments.ProjectID#">
		</cfquery>
		<div class="panel panel-default">
				<div class="panel-heading">Test Scenario Status<div class="btn-group" style="float:right;margin-top:-5px;"><a href="##" class="lnkAddScenario btn btn-info btn-sm"><i class="fa fa-plus-square"></i> Add Scenario</a><a href="http://#Application.HttpsUrl#/CFTestTrack/project/#arguments.projectid#/allscenarios/" class="btn btn-info btn-sm"><i class="fa fa-list"></i> View All</a></div></div>
				<div class="panel-body">
					<cfif ArrayLen(qryTestScenarios) gt 0>
					<table class="table table-striped table-condensed">
						<thead>
							<th>Test Scenario</th>
							<th>Tests Assigned</th>
							<th></th>
						</thead>
						<tbody>
							<cfloop array="#qryTestScenarios#" index="scenario">
								<cfset objData = createObject("component","Data")>
								<cfset qryTestCases = objData.qryTestCaseForScenarios(scenario.getId())>
								<tr>
									<td><a href="http://#Application.HttpsUrl#/CFTestTrack/scenario/#scenario.getId()#/" scenarioid="#scenario.getId()#"><cfif Len(scenario.getAxoSoftNumber()) gt 0>#scenario.getAxoSoftNumber()# - </cfif>#scenario.getTestScenario()#</a></td>
									<td>(#qryTestCases.RecordCount#)</td>
									<td><a href="##" class="lnkEditScenario btn btn-default btn-xs" scenarioid="#scenario.getId()#"><i class="fa fa-pencil"></i> Edit</a>&nbsp;&nbsp;<a href="##" class="lnkDeleteScenario btn btn-danger btn-xs" scenarioid="#scenario.getId()#"><i class="fa fa-trash"></i> Delete</a></td>
								</tr>
							</cfloop>
						</tbody>
					</table>
					<cfelse>
					<div class="alert alert-warning"><h4>This project doesn't contain any test scenarios.</h4>Please add one from the Test Scenarios above.  You can also add Test Sections to better organize your testing.</div>
					</cfif>
				</div>
			</div>
	</cffunction>
	
	<cffunction name="getTestResult" access="remote" output="true" httpmethod="GET">
		<cfargument name="testresultid" required="true">
		<cfset arrTestResult = EntityLoadByPK("TTestResult",arguments.testresultid)>
		<cfset arrTestCase = EntityLoadByPK("TTestCase",arrTestResult.getTestCaseID())>
		<cfscript>
			writeOutput("<h2>"&arrTestCase.getTestTitle()&"</h2>"&chr(13));
			writeOutput("<h3><span class='label " & returnBSLabelStyle(arrTestResult.getTTestStatus().getStatus()) & "'>" & arrTestResult.getTTestStatus().getStatus() & "</span>" & DateFormat(arrTestResult.getDateTested(),"mm/dd/yyyy")&"</h3>");
			writeOutput("<p><strong>Comments:</strong><br />" & arrTestResult.getComment() & "</p>");
			writeOutput("<p><strong>Defects:</strong><br />" & arrTestResult.getDefects() & "</p>");
			writeOutput("<p><strong>Elapsed Time:</strong> " & arrTestResult.getElapsedTime() & "</p>");			
		</cfscript>
	</cffunction>	
		
	<cffunction name="HubChart" access="public" output="true">
		<cfargument name="projectid" required="false" default="0">
		<cfquery name="qryName" dbtype="hql">
			FROM TTestProject
			WHERE id = <cfqueryparam value="#arguments.projectid#">
		</cfquery>
		<h1 class="page-header">#qryName[1].getProjectTitle()#</h1>
		<div id="topcontent" class="panel panel-default">
		<div class="panel-heading" id="activitytitle"><span class="label label-info">P#qryName[1].getId()#</span> #qryName[1].getProjectTitle()#</div>
		<div class="panel-body">
		<cfset qryCounts = objData.qryCounts(arguments.projectid)>
		<cfscript>
			local.TotalPassedCount = 0;
			local.TotalFailedCount = 0;
			local.TotalUntestedCount = 0;
			local.TotalBlockedCount = 0;
			local.TotalRetestCount = 0;
		</cfscript>
		<cfloop query="qryCounts">
			<cfset local.TotalPassedCount = local.TotalPassedCount + PassedCount />
			<cfset local.TotalFailedCount = local.TotalFailedCount + FailedCount />
			<cfset local.TotalUntestedCount = local.TotalUntestedCount + UntestedCount />
			<cfset local.TotalBlockedCount = local.TotalBlockedCount + BlockedCount />
			<cfset local.TotalRetestCount = local.TotalRetestCount + RetestCount />
			
		</cfloop>
		<cfset local.TotalCount = local.TotalBlockedCount + local.TotalFailedCount + local.TotalPassedCount + local.TotalRetestCount + local.TotalUntestedCount/>
		<cfset local.PassedPercent = (local.TotalCount gt 0) ? (local.TotalPassedCount / local.TotalCount) * 100 : 0 >
		<cfset local.FailedPercent = (local.TotalCount gt 0) ? (local.TotalFailedCount / local.TotalCount) * 100 : 0>
		<cfset local.UntestedPercent = (local.TotalCount gt 0) ?  (local.TotalUntestedCount / local.TotalCount) * 100 : 0>
		<cfset local.BlockedPercent = (local.TotalCount gt 0) ? (local.TotalBlockedCount / local.TotalCount) * 100 : 0>
		<cfset local.RetestPercent = (local.TotalCount gt 0) ? (local.TotalRetestCount / local.TotalCount) * 100 : 0> 
		<div class="col-xs-9 col-sm-9 col-md-9 col-lg-9"><canvas id="chartcanvas" name="chartcanvas" width="100%" height="300" /></div>
		<div class="col-xs-3 col-sm-3 col-md-3 col-lg-3">
			<p><span class="label label-success">#local.TotalPassedCount# Passed</span><br />#NumberFormat(local.PassedPercent,"0.00")#% set to Passed</p>
			<p><span class="label label-default">#local.TotalBlockedCount# Blocked</span><br />#NumberFormat(local.BlockedPercent,"0.00")#% set to Blocked</p>
			<p><span class="label label-warning">#local.TotalRetestCount# Retest</span><br />#NumberFormat(local.RetestPercent,"0.00")#% set to Retest</p>
			<p><span class="label label-danger">#local.TotalFailedCount# Failed</span><br />#NumberFormat(local.FailedPercent,"0.00")#% set to Failed</p>
			<p><span class="label label-info">#local.TotalUntestedCount# Untested</span><br />#NumberFormat(local.UntestedPercent,"0.00")#% set to Untested</p>
		</div>
		<script type="text/javascript">
			var barData = {
						labels : [#Replace(QuotedValueList(qryCounts.DateTested,","),"/","\/","all")#],
						datasets : [
							{
								title : "Passed",
								strokeColor : "##5cb85c",
								data : [#ValueList(qryCounts.PassedCount,",")#]
							},
							{
								title : "Failed",
								strokeColor : "##d9534f",
							    data : [#ValueList(qryCounts.FailedCount,",")#]
							},
							{
								title : "Untested",
								strokeColor : "##5bc0de",
								data : [#ValueList(qryCounts.UntestedCount,",")#]
							},
							{
								title : "Blocked",
								strokeColor : "##777",
								data : [#ValueList(qryCounts.BlockedCount,",")#]
							},
							{
								title : "Retest",
								strokeColor : "##f0ad4e",
								data : [#ValueList(qryCounts.RetestCount,",")#]
							}
						]
					}
					var options = {
						canvasBorders : false,
						legend : false,
						yAxisMinimumInterval : 1,
						scaleStartValue : 0,
						xAxisLabel : "Date",
						yAxisLabel : "Count",
						savePng : true,
						savePngOutput : "Save",
						savePngName: "Activity",
						savePngBackgroundColor : "white",
						annotateDisplay : true,
						graphTitle: "Testing Activity",
						responsive: true,
						responsiveMaxHeight: 300,
						maintainAspectRatio: false
					};
					var chartObj = new Chart(document.getElementById("chartcanvas").getContext("2d")).Line(barData,options);
					// -->
				</script>
			</div>
			</div>
	</cffunction>
	
	<cffunction name="HubDonutChart" access="remote" output="true" httpmethod="POST">
		<cfargument name="projectid" required="false" default="0">
		<cfquery name="qryName" dbtype="hql">
			FROM TTestProject
			WHERE id = <cfqueryparam value="#arguments.projectid#">
		</cfquery>
		<div id="topcontent" class="panel panel-default">
		<div class="panel-heading" id="activitytitle">#qryName[1].getProjectTitle()#</div>
		<div class="panel-body">
		<cfset qryCounts = objData.qryTestResultCountsTotal(arguments.projectid) />
		<div class="col-xs-9 col-sm-9 col-md-9 col-lg-9"><canvas id="chartcanvas" name="chartcanvas" width="100%" height="300" /></div>
		<div class="col-xs-3 col-sm-3 col-md-3 col-lg-3">
			<cfset local.totals = 0>
			<cfloop query="qryCounts">
				<cfset local.totals += ItemCount>
			</cfloop>
			<cfloop query="qryCounts">
			<p><span class="label #returnBSLabelStyle(Status)#">#ItemCount# #Status#</span><br />#NumberFormat((ItemCount / local.totals) * 100,"0.0")#% set to #Status#</p>
			</cfloop>
		</div>
		<script type="text/javascript">
			var donutData = [
							<cfloop query="qryCounts">
							{
								title : "#Status#",
								<cfswitch expression="#Status#">
								<cfcase value="Passed">
								color : "##5cb85c",
								</cfcase>
								<cfcase value="Failed">
								color : "##d9534f",
								</cfcase>
								<cfcase value="Untested,Assigned,Created">
								color : "##5bc0de",
								</cfcase>
								<cfcase value="Blocked">
								color : "##777",
								</cfcase>
								<cfcase value="Retest">
								color : "##f0ad4e",
								</cfcase>
								</cfswitch>
								value : #ItemCount#
							}
							<cfif currentRow LT qryCounts.RecordCount>,</cfif>
							</cfloop>
						];
					
					var donutoptions = {
						canvasBorders : false,
						legend : false,
						scaleOverride : false,
						scaleStartValue : null,
						savePng : true,
						savePngOutput : "Save",
						savePngName: "System Totals",
						savePngBackgroundColor : "white",
						annotateDisplay : true,
						inGraphDataShow: true,
						graphTitle : "System Totals",
						responsive: true,
						responsiveMaxHeight: 300,
						maintainAspectRatio: false
					};
					var chartObj = new Chart(document.getElementById("chartcanvas").getContext("2d")).Doughnut(donutData,donutoptions);
				</script>
				</div>
			</div>
	</cffunction>
	
	<cffunction name="mileStoneTimeline" access="remote" output="true">
		<cfargument name="projectid" required="true" />
		<cfset objMilestones = EntityLoad("TTestMilestones",{ProjectID = arguments.projectid}, false) />
		<div class="panel panel-default">
                        <div class="panel-heading">
                            <i class="fa fa-clock-o fa-fw"></i> Milestone Timeline
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <ul class="timeline">
                            	<cfset i = 1 />
                            	<cfloop array="#objMilestones#" index="milestone">
                                <li<cfif i mod 2 eq 0> class="timeline-inverted"</cfif>>
                                    <div class="timeline-badge<cfif milestone.GetDueOn() LT Now()> danger</cfif>"><i class="fa fa-check"></i>
                                    </div>
                                    <div class="timeline-panel">
                                        <div class="timeline-heading">
                                            <h4 class="timeline-title<cfif milestone.GetDueOn() LT Now()> danger</cfif>">#milestone.GetMilestone()#</h4>
                                            <p><small class="text-muted"><i class="fa fa-clock-o"></i> Due on: #milestone.GetDueOn()#</small>
                                            </p>
                                        </div>
                                        <div class="timeline-body">
                                            <p>#milestone.getMilestoneDescription()#</p>
                                        </div>
                                    </div>
                                </li>
                                <cfset i = i + 1 />
                                </cfloop>
                                <!---<li class="timeline-inverted">
                                    <div class="timeline-badge warning"><i class="fa fa-credit-card"></i>
                                    </div>
                                    <div class="timeline-panel">
                                        <div class="timeline-heading">
                                            <h4 class="timeline-title">Lorem ipsum dolor</h4>
                                        </div>
                                        <div class="timeline-body">
                                            <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Autem dolorem quibusdam, tenetur commodi provident cumque magni voluptatem libero, quis rerum. Fugiat esse debitis optio, tempore. Animi officiis alias, officia repellendus.</p>
                                            <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Laudantium maiores odit qui est tempora eos, nostrum provident explicabo dignissimos debitis vel! Adipisci eius voluptates, ad aut recusandae minus eaque facere.</p>
                                        </div>
                                    </div>
                                </li>--->
                                </ul>
                        	</div>
                    	</div>
	</cffunction>
	
	<cffunction name="UserDashPart" access="remote" output="true">
			<div class="row">
				<div class="col-lg-4 col-md-6">
				<div class="panel panel-primary">
            		<div class="panel-heading">
            			<div class="row">
	                		<div class="col-xs-3">
    	            			<i class="fa fa-users fa-5x"></i>
    	            		</div>
        	        		<div class="col-xs-9 text-right">
        	        			<div class="huge">#arrayLen(objData.getAllTesters())#</div>
        	        			<div>Users</div>
        	        		</div>
            			</div>
            		</div>
            		<a href="##">
	            	<div class="panel-footer">
                        <span class="pull-left">View Details</span>
                        <span class="pull-right"><i class="fa fa-arrow-circle-right"></i></span>
                        <div class="clearfix"></div>
                    </div>
                    </a>
        		</div>
        		</div>
        		<div class="col-lg-4 col-md-6">
        			<div class="panel panel-green">
        				<div class="panel-heading">
        					<div class="row">
        						<div class="col-xs-3">
        							<i class="fa fa-wrench fa-5x"></i>
        						</div>
        						<div class="col-xs-9 text-right">
        							<div class="huge"><cfoutput>#ArrayLen(objData.getAllProjects())#</cfoutput></div>
        							<div>Total Projects</div>
        						</div>
        					</div>
        				</div>
        				<a href="##">
        					<div class="panel-footer">
        						<span class="pull-left">View Details</span>
        						<span class="pull-right"><i class="fa fa-arrow-circle-right"></i></span>
        						<div class="clearfix"></div>
        					</div>
        				</a>
        			</div>
        		</div>
        		<div class="col-lg-4 col-md-6">
        			<div class="panel panel-yellow">
        				<div class="panel-heading">
        					<div class="row">
        						<div class="col-xs-3">
        							<i class="fa fa-tachometer fa-5x"></i>
        						</div>
        						<div class="col-xs-9 text-right">
        							<div class="huge">#objData.getAllOpenCases().RecordCount#</div>
        							<div>Total Open Tests</div>
        						</div>
        					</div>
        				</div>
        				<a href="##">
        					<div class="panel-footer">
        						<span class="pull-left">View Details</span>
        						<span class="pull-right"><i class="fa fa-arrow-circle-right"></i></span>
        						<div class="clearfix"></div>
        					</div>
        				</a>
        			</div>
        		</div>
        		
        	</div>  	
	</cffunction>
	
	<cffunction name="AllProjectsChart" access="remote" output="true">
		<cfdbinfo type="version" name="dbInfo">
		<cfset qryGeneralActivity = objData.qryGeneralActivity()>
		<cfset arrColor = ['red','green','blue','yellow','gray','black','pink','brown'] />
		<div class="panel panel-default">
		<div class="panel-heading" id="activitytitle"><i class="fa fa-pie-chart"></i> All Projects</div>
		<div class="panel-body">
			<div class="col-xs-9 col-sm-9 col-md-9 col-lg-9"><canvas id="chartcanvas" name="chartcanvas" width="100%" height="300" /></div>
			<div class="col-xs-3 col-sm-3 col-md-3 col-lg-3">
				<h5>Most Activity</h5>
				<cfif qryGeneralActivity.RecordCount eq 0>
					<div class="col-xs-4 col-sm-4 col-md-4 col-lg-4 text-right" >
						<div style='width:32px;height:32px;background-color:##777;border: 1px solid ##666;float:right;'>&nbsp;</div>
					</div>
					<div class="col-xs-8 col sm-8 col-md-8, col-lg-8 text-left" style="padding-left:0px;">
						<strong>No project activity</strong>
					</div>
					<div class="clearfix">&nbsp;</div>
				</cfif>
				<cfloop query="qryGeneralActivity">
					<!--- generate random color for each row, captured in array for later use--->
					<!---<cfset arrColor[currentRow] = FormatBaseN((RandRange(0,255)+102)/2, 16) & FormatBaseN((RandRange(0,255)+205)/2, 16) & FormatBaseN((RandRange(0,255)+170)/2, 16)>--->
					<div class="col-xs-4 col-sm-4 col-md-4 col-lg-4 text-right">
						<div style='width:32px;height:32px;background-color:###qryGeneralActivity.Color#;border: 1px solid ##666;float:right;'>&nbsp;</div>
					</div>
					<div class="col-xs-8 col sm-8 col-md-8, col-lg-8 text-left" style="padding-left:0px;">
						<h6>#ProjectTitle#</h6>
					</div>
					<div class="clearfix">&nbsp;</div>
				</cfloop>
			</div>
		</div>
		<cfset local.cols = ListDeleteAt(ArrayToList(qryGeneralActivity.getColumnNames()),1,",")>
		<cfset local.cols = ListDeleteAt(local.cols,1,",")> <!--- do this twice to purge the color column value, too --->
		<script type="text/javascript">
			var barData = {
						labels : [<cfloop list="#cols#" index="col">"#col#"<cfif ListFindNoCase(cols,col,",") LT ListLen(cols)>,</cfif></cfloop>],
						datasets : [
							<cfif qryGeneralActivity.RecordCount eq 0>
							{
								title : "",
								strokeColor: "##777",
								data: [0]
							}
							</cfif>
							<cfloop query="qryGeneralActivity">
							{
								title : "#qryGeneralActivity.ProjectTitle#",
								strokeColor : "###qryGeneralActivity.Color#",
								data : [<cfloop list="#cols#" index="col">#qryGeneralActivity[col][currentRow]#<cfif ListFindNoCase(cols,col,",") LT ListLen(cols)>,</cfif></cfloop>]
							}
							<cfif currentRow NEQ qryGeneralActivity.RecordCount>,</cfif>
							</cfloop>
						]
					}
					var options = {
						canvasBorders : false,
						legend : false,
						yAxisMinimumInterval : 8,
						scaleStartValue : 0,
						//xAxisLabel : "Date",
						//yAxisLabel : "Count",
						savePng : true,
						savePngOutput : "Save",
						savePngName: "Test Activity",
						savePngBackgroundColor : "white",
						responsive: true,
						responsiveMaxHeight: 300,
						maintainAspectRatio: false,
						annotateDisplay : true //,
						//graphTitle: "Testing Activity - 14 Days"
					};
					var chartObj = new Chart(document.getElementById("chartcanvas").getContext("2d")).Line(barData,options);
		</script>
		</div>
	</cffunction>
	
	<cffunction name="chartList" access="remote" returnformat="JSON" returntype="string">
		<cfset var data="" />
		<cfset var result= ArrayNew(1) />
		<cfscript>
			hubChart = StructNew();
			hubchart["opticon"] = "fa-line-chart";
			hubChart["optlabel"] = "Activity";
			hubChart["optvalue"] = "HubChart";
			ArrayAppend(result,hubChart);
			hubPieChart = StructNew();
			hubPieChart["opticon"] = "fa-pie-chart";
			hubPieChart["optlabel"] = "System Activity";
			hubPieChart["optvalue"] = "HubDonutChart";
			ArrayAppend(result,hubPieChart);
		</cfscript>
		<cfreturn serializeJSON(result) />
	</cffunction>

	<!--- other non report/chart sections that return rich content --->
	
	<cffunction name="Actions" access="remote" output="true">
		<cfif !StructKeyExists(Session,"ProjectID")>
			<cfreturn>
		</cfif>
		<div id="panel-actions" class="panel panel-default">
			<div class="panel-heading"><i class="fa fa-rocket"></i> Online Users</div>
			<div class="panel-body">
			<cfscript>
				arrKeys = StructKeyArray(application.SessionTracker);
				for (i = 1; i <= ArrayLen(arrKeys); i++ )
				{
					arrUser = EntityLoadByPK("TTestTester",arrKeys[i]);
					writeOutput("<div class='row rowoffset'>" & chr(13));
					writeOutput("	<div class='col-xs-3 col-sm-3 col-md-3 col-lg-3 text-right;'>" & chr(13));
					if ( FileExists(ExpandPath("/avatars/") & arrKeys[i] & ".png") ) {
						writeOutput("		<img src='images/avatars/" & arrKeys[i] & ".png' style='max-width:100%;max-height:100%;' class='avatar' />" & chr(13));
					} else {
						writeOutput("		<img src='images/avatars/none.png' style='max-width:100%;max-height:100%;' class='avatar' />" & chr(13));
					}
					writeOutput("</div><div class='col-xs-9 col-sm-9 col-md-9 col-lg-9'><br /><span style='font-weight: bold;'>" & arrUser.getUserName() & "</span><br /><a href='##' class='btn btn-primary btn-xs'>Send File</a>&nbsp;&nbsp;");
					if ( Application.EnableChat ) {
						writeOutput("|&nbsp;&nbsp;<a href='##' class='chat btn btn-primary btn-xs' fromid='"&Session.UserIDInt&"' toid='" & arrUser.getId() & "' >Chat");
						if ( Application.UserChatCount[Session.UserIDInt] > 0 && Application.UserChatCount[Session.UserIDInt] == arrUser.getID()) {
							writeOutput("    <span class='badge' style='background-color:##f00;color:##fff;'>New</span>");
						}
						writeOutput("</a>");
					}
					writeOutput("</div>");
					writeOutput("	</div>" & chr(13));
				}
				writeOutput("</div>");
			</cfscript>
			</div>
		</div>
	</cffunction>
		
	<cffunction name="AllReports" access="remote" output="true">
		<cfargument name="projectid" required="true" />
		<h1>Reporting</h1>
		<div class="panel panel-default">
			<div class="panel-heading"><strong><i class="fa fa-bars"></i> </strong></div>
			<div class="panel-body">
				<Cfif Len(Session.ProjectID) eq 0>
					<cfset arrReports = EntityLoad("TTestReports")>
				<cfelse>
					<cfset arrReports = EntityLoad("TTestReports",{ProjectID = arguments.ProjectID},{maxresults=10})>
				</Cfif>
				<cfif ArrayLen(arrReports) GT 0>
					<div class="well well-sm" style="font-weight:bold;">Configured Reports</div>
					<table class="table table-striped table-condensed table-hover">
						<thead>
							<tr>
								<th>Report Type</th>
								<th>Report Name</th>
								<th>Report Time Span</th>
								<th>Report Frequency</th>
								<th></th>
							</tr>
						</thead>
						<tbody>
							<cfloop array="#arrReports#" index="report">
								<cfset optionsStruct = objFunctions.toCFML(report.getReportOptions())>
								<cfset skedStruct = objFunctions.toCFML(report.getReportAccessAndScheduling())>
							<tr>
								<td>#report.getReportTypeName()#</td>
								<td>#report.getReportName()#</td>
								<td>#optionsStruct.TimeFrame#</td>
								<td>#skedStruct.CreateReport#</td>
								<td><div class="btn-group"><a class="btn btn-primary btn-sm" href="/CFTestTrack/reportpdfs/#report.getId()#.pdf" target="_blank">View</a><a class="lnkReportDelete btn btn-primary btn-sm" reportid="#report.getId()#" href="##">Delete</a></div></td>
							</tr>
							</cfloop>
						</tbody>
					</table>
				<cfelse>
						
				<div class='alert alert-danger' role='alert'><strong>There are no reports configured.</strong><br />Set up reports by selecting report types from the left.</div>
				</cfif>
				<cfset objMaintenance = createObject("component","Maintenance")>
				<cfset qryTasks = objMaintenance.returnTasks()>
				<cfif qryTasks.RecordCount gt 0>
					<div class="well well-sm" style="font-weight:bold;">Scheduled Reports</div>
					<table class="table table-striped table-condensed table-hover">
						<thead>
							<tr>
							<th>Task</th>
							<th>Interval</th>
							<th>Start Date</th>
							<th>Last Run</th>
							</tr>
						</thead>
						<tbody>
						<cfloop query="qryTasks">
							<tr>
								<td>#task#</td>
								<td>#interval#</td>
								<td><cfif isDefined("start_date")>#DateFormat(start_date,"mm/dd/yyyy")#<cfelse>#DateFormat(startdate,"mm/dd/yyyy")#</cfif></td>
								<td><cfif isDefineD("last_run")>#last_run#<cfelse>#last_fire#</cfif></td>
							</tr>
						</cfloop>
						</tbody>
					</table>
				</cfif>
					</div>
		</div>
	</cffunction>
	
	<cffunction name="AllMilestones" access="remote" output="true">
		<cfargument name="projectid">
		<cfif (!StructKeyExists(SESSION,"Loggedin") || !Session.Loggedin)>
			<cfreturn>
		</cfif>		
		<cfset arrMilestones = EntityLoad("TTestMilestones",{ProjectID = arguments.ProjectID},"DueOn ASC")>
		<h1 class="page-header">Project Milestones</h1>
		<div id="allmilestonespanel" class="panel panel-default">
			<div class="panel-heading"><i class="fa fa-map-marker"></i> <strong>Milestones</strong></div>
			<div class="panel-body">
				<cfif ArrayLen(arrMilestones) gt 0>
				<div class="well well-sm" id="overduewell" style="display:none;color:##F00;font-weight:bold;">Overdue</div>
				<table class="table table-striped">
				<tbody>
				<cfset overdueCount = 0>
				<cfloop array="#arrMilestones#" index="milestone">
					<cfif milestone.getDueOn() lt Now() and milestone.getClosed() eq false>
					<cfset overdueCount = overdueCount + 1>
					<tr>
						<td>
							<h5>#milestone.getMilestone()#</h5>Due on #DateFormat(milestone.getDueon(),"m/d/yyyy")#
						</td>
						<td><a href="##" class="lnkEditMilestone btn btn-default btn-xs" milestoneid="#milestone.getId()#"><i class="fa fa-pencil"></i> Edit</a>&nbsp;&nbsp;<a href="##" class="lnkDeleteMilestone btn btn-danger btn-xs" projectid="#arguments.projectid#"  milestoneid="#milestone.getId()#"><i class="fa fa-trash"></i> Delete</a>
							<cfif overdueCount eq 1>
								<script type="text/javascript">
									$(document).ready(function() {
										$("##overduewell").show();
									});
								</script>
							</cfif>
						</td>
						<td><!--- insert progress bar ---></td>
					</tr>
					</cfif>
				</cfloop>
				</tbody>
				</table>
				<div class="well well-sm" id="openmilestoneswell" style="display:none;font-weight:bold;">Open Milestones</div>
				<table class="table table-striped">
				<tbody>
				<cfset openCount = 0>
				<cfloop array="#arrMilestones#" index="milestone">
					<cfif milestone.getDueOn() gte Now() and milestone.getClosed() eq false>
					<cfset openCount = openCount + 1>
					<tr>
						<td>
							<h5>#milestone.getMilestone()#</h5>Due on #DateFormat(milestone.getDueOn(),"m/d/yyyy")#
						</td>
						<td><a href="##" class="lnkEditMilestone btn btn-default btn-xs" milestoneid="#milestone.getId()#"><i class="fa fa-pencil"></i> Edit</a>&nbsp;&nbsp;<a href="##" class="lnkDeleteMilestone btn btn-danger btn-xs" milestoneid="#milestone.getId()#"><i class="fa fa-trash"></i> Delete</a>
							<cfif openCount eq 1>
								<script type="text/javascript">
									$(document).ready(function() {
										$("##openmilestoneswell").show();
									});
								</script>
							</cfif>
						</td>
						<td><!--- insert progress bar ---></td>
					</tr>
					</cfif>
				</cfloop>
				</tbody>
				</table>
				<div class="well well-sm" id="closedmswell" style="display:none;font-weight:bold;">Completed Milestones</div>
				<table class="table table-striped">
				<tbody>
				<cfset closedCount = 0>
				<cfloop array="#arrMilestones#" index="milestone">
					<cfif milestone.getClosed() eq true>
					<cfset closedCount = closedCount + 1>
					<tr>
						<td>
							<h5>#milestone.getMilestone()#</h5>Due on #DateFormat(milestone.getDueOn(),"m/d/yyyy")#
						</td>
						<td><a href="##" class="lnkEditMilestone btn btn-default btn-xs" milestoneid="#milestone.getId()#"><i class="fa fa-pencil"></i> Edit</a>
							<cfif closedCount eq 1>
								<script type="text/javascript">
									$(document).ready(function() {
										$("##closedmswell").show();
									});
								</script>
							</cfif>
						</td>
						<td><!--- insert progress bar ---></td>
					</tr>
					</cfif>
				</cfloop>
				</tbody>
				</table>
				<cfelse>
				<div class="alert alert-warning"><h4>This project doesn't contain any milestones.</h4>Please add one from the actions link to the right.</div>
				</cfif>
			</div>
		</div>
	</cffunction>						
	
	<cffunction name="AllScenarios" access="remote" output="true">
		<cfargument name="projectid">
		<cfargument name="start" default="1">
		<cfargument name="searchstring" default="">
		<cfif (!StructKeyExists(SESSION,"Loggedin") || !Session.Loggedin)>
			<cfreturn>
		</cfif>
		
		<cfset qryCount = "SELECT count(*) FROM TTestScenario WHERE ProjectID = #arguments.ProjectID#">
		<cfset countresults = ORMExecuteQuery(qryCount)[1]>
		<script type="text/javascript">
			$(document).ready(function() {
				$(document).off("click",".pagination li a");
				$(document).on("click",".pagination li a",function() {
					var pagenum = $(this).text();
					<cfif Len(arguments.searchstring) gt 0>
						$.ajax({url:"/CFTestTrack/cfc/Dashboard.cfc?method=AllScenarios",type:"POST",data : { projectid: #arguments.projectid#, start: pagenum, searchstring : "#arguments.searchstring#"  } }).done(function(data) { $("##topcontent").html(data); });
					<cfelse>
					$("##scenariospanel").parent().load("/CFTestTrack/cfc/Dashboard.cfc?method=AllScenarios&projectid=#arguments.projectid#&start="+pagenum);
					</cfif>
				});
				$(document).off("click","##btnsearch");
				$(document).on("click","##btnsearch", function() {
					$.ajax({url:"/CFTestTrack/cfc/Dashboard.cfc?method=AllScenarios", type: "POST", data: { projectid: #arguments.projectid#, searchstring : $("##searchstring").val() 
					}}).done(function(data) {
						$("##scenariospanel").parent().html(data);
					});
				});
			});
		</script>
		<cfif Len(arguments.searchstring) gt 0>
			<cfset stringsearch = URLDecode(arguments.searchstring)>
			<cfset arrTestScenarios = ORMExecuteQuery("FROM TTestScenario WHERE (TestScenario LIKE '%#stringsearch#%' OR TestDescription LIKE '%#stringsearch#%' OR AxoSoftNumber LIKE '%#stringsearch#%') AND ProjectID = #Session.ProjectID# ORDER BY AxoSoftNumber DESC, ProjectID Desc",false,{maxresults=20,offset=(arguments.start-1)*20}) />
			<cfset qryCount = "SELECT count(*) FROM TTestScenario  WHERE (TestScenario LIKE '%#stringsearch#%' OR TestDescription LIKE '%#stringsearch#%' OR AxoSoftNumber LIKE '%#stringsearch#%') AND ProjectID = #Session.ProjectID#">
			<cfset countresults = ORMExecuteQuery(qryCount)[1]>
		<cfelse>
			<cfset arrTestScenarios = EntityLoad("TTestScenario",{ProjectID = Session.ProjectID},"AxoSoftNumber Desc, ProjectID Desc",{maxresults=20,offset=(arguments.start-1)*20})>
		</cfif>
		<cfset objData = createObject("component","Data")>
		<h1 class="page-header">All Test Scenarios</h1>
		<div id="scenariospanel" class="panel panel-default">
			<div class="panel-heading"><i class="fa fa-tachometer"></i> <strong>Test Scenarios</strong></div>
			<div class="panel-body">
				<div class="well well-sm" style="font-weight:bold;">Active<div class="col-lg-3 col-md-3 col-sm-3 col-xs-3 input-group" style="float:right;margin-top:-7px;"><input type='text' class='form-control' id='searchstring' name='searchstring' placeholder="Search for..." <cfif len(arguments.searchstring) gt 0>value="#arguments.searchstring#"</cfif> /><span class="input-group-btn"><button id='btnsearch' class='btn btn-primary'><i class='fa fa-search'></i></button></span></div></div>
				<cfset numPages = ceiling(countresults / 20)>
				<cfif ArrayLen(arrTestScenarios) gt 0>
				<cfif numPages gt 1>
				<ul class="pagination">
					<cfloop from="1" to="#numPages#" index="i">
						<li<cfif i eq arguments.start> class="active"</cfif>><a href="##">#i#</a><li>
					</cfloop>
				</ul>
				</cfif>
				<table class="table table-striped">
				<tbody>
					<cfloop array="#arrTestScenarios#" index="scenario">
					<cfset qryTestCases = objData.qryTestCaseForScenarios(scenario.getId())><!--- get total record count --->
					<!--- subcounts --->
					<cfset qryTestCounts = objData.qryTestCaseHistoryForScenarios(scenario.getId())>
						<tr>
							<td><h5><a href="/CFTestTrack/scenario/#scenario.getId()#/"><cfif len(scenario.getAxoSoftNumber()) gt 0>#scenario.getAxoSoftNumber()# - </cfif>#scenario.getTestScenario()#</a><h5>
								<cfset untestedPercent = 0>
								<cfset blockedPercent = 0>
								<Cfset retestPercent = 0>
								<Cfset passedPercent = 0>
								<cfset failedPercent = 0>
								<cfloop query="qryTestCounts">
									<!--- conditional for percentage counts --->
									<cfif Status eq "Untested">
										<cfset untestedPercent = (StatusCount gt 0 AND qryTestCases.RecordCount gt 0) ? (StatusCount / qryTestCases.RecordCount) * 100 : 0>
									</cfif>
									<cfif Status eq "Blocked">
										<cfset blockedPercent = (StatusCount gt 0 AND qryTestCases.RecordCount gt 0) ? (StatusCount / qryTestCases.RecordCount) * 100 : 0>
									</cfif>
									<cfif Status eq "Retest">
										<cfset retestPercent = (StatusCount gt 0 AND qryTestCases.RecordCount gt 0) ? (StatusCount / qryTestCases.RecordCount) * 100 : 0>
									</cfif>
									<cfif Status eq "Passed">
										<cfset passedPercent = (StatusCount gt 0 AND qryTestCases.RecordCount gt 0) ? (StatusCount / qryTestCases.RecordCount) * 100 : 0>
									</cfif>
									<cfif Status eq "Failed">
										<cfset failedPercent = (StatusCount gt 0 AND qryTestCases.RecordCount gt 0) ? (StatusCount / qryTestCases.RecordCount) * 100 : 0>
									</cfif>
									<strong>#StatusCount#</strong> #Status#<cfif currentRow lt qryTestCounts.RecordCount>,</cfif>
								</cfloop>
							</td>
							<td><a href="##" class="lnkEditScenario btn btn-default btn-xs" scenarioid="#scenario.getId()#"><i class="fa fa-pencil"></i> Edit</a>&nbsp;&nbsp;<a href="##" class="lnkDeleteScenario btn btn-danger btn-xs" scenarioid="#scenario.getId()#" projectid="#arguments.projectid#"><i class="fa fa-trash"></i> Delete</a></td>
							<td style="width:33%"><div class="progress active">
									<cfif passedPercent gt 0>
									<div class="progress-bar progress-bar-success progress-bar-striped" style="width:#passedPercent#%;">
										<span class="sr-only">#passedPercent#% Passed</span>
									</div>
									</cfif>
									<cfif retestPercent gt 0>
									<div class="progress-bar progress-bar-warning progress-bar-striped" style="width:#retestPercent#%;">
										<span class="sr-only">#retestPercent#% Retest</span>
									</div>
									</cfif>
									<cfif failedPercent gt 0>
									<div class="progress-bar progress-bar-danger progress-bar-striped" style="width:#failedPercent#%;">
										<span class="sr-only">#failedPercent#% Failed</span>
									</div>
									</cfif>
									<cfif untestedPercent gt 0>
									<div class="progress-bar progress-bar-info progress-bar-striped" style="width:#untestedPercent#%;">
										<span class="sr-only">#untestedPercent#% Untested</span>
									</div>
									</cfif>
									<cfif blockedPercent gt 0>
									<div class="progress-bar progress-bar-default progress-bar-striped" style="width:#blockedPercent#%;">
										<span class="sr-only">#blockedPercent#% Blocked</span>
									</div>
									</cfif>
								</div>
									
							</td>
						</tr>
					</cfloop>
				</tbody>
				</table>
				<cfif numPages gt 1>
				<ul class="pagination">
					<cfloop from="1" to="#numPages#" index="i">
						<li<cfif i eq arguments.start> class="active"</cfif>><a href="##">#i#</a><li>
					</cfloop>
				</ul>
				</cfif>
				<cfelse>
				<cfif len(arguments.searchstring) lte 0>
				<div class="alert alert-warning"><h4>This project doesn't contain any test scenarios.</h4>Please add one from the Test Scenarios menu above.</div>
				<cfelse>
				<div class="alert alert-warning"><h4>No results found.</h4>Refine your search and try again.</div>
				</cfif>
				</cfif>				
			</div>
	</cffunction>
	
	<cffunction name="AllTests" access="remote" output="true">
		<cfargument name="projectid">
		<cfset objData = createObject("component","Data")>
		<cfset arrTestCases = objData.getTestCasesByProject(arguments.ProjectID)>
		<h1 class="page-header">All Test Cases</h1>
		<div id="panelalltestcases" class="panel panel-default">
			<div class="panel-heading"><i class="fa fa-tachometer"></i> <strong>Test Cases</strong></div>
			<div class="panel-body">
				<cfif ArrayLen(arrTestCases) gt 0>
				<div class="navbar" style="margin-right: 10px;">
					<div class="navbar-inner">
						<ul class="nav navbar-nav navbar-right">
							<li><div class="btn-group">
								<a href="##" class="lnkDownloadTestCaseTemplate btn btn-info">Download Test Case Template (*.xls)</a>
								<a href="##" class="lnkUploadTestCases btn btn-info">Upload Via Excel</a></div>
							</li>
						</ul>
					</div>
				</div>
				<h4>All Test Cases</h4>
				<table class="table table-condensed table-striped table-hover">
					<thead>
						<tr>
							<th></th>
							<th>Case ID</th>
							<th>Test Title</th>
							<th></th>
							<th></th>
						</tr>
					</thead>
					<tbody>
						<cfloop array="#arrTestCases#" index="case">
						<tr>
							<td><input type="checkbox" id="cbxTestCase" caseid="#case.getId()#" /></td>
							<td><span class="label label-info">TC#case.getId()#</label></td>
							<td>#case.getTestTitle()#</td>
							<td><a href="##" class="testcaseeditlink btn btn-default btn-xs" editid="#case.getId()#"><i class="fa fa-pencil"></i> Edit</a></td>
							<td><cfif Application.AllowCaseDelete eq "true"><a href="##" class="testcasedeletelink btn btn-danger btn-xs" editid="#case.getId()#" projectid="#arguments.projectid#"><i class="fa fa-trash"></i> Delete</a></cfif></td>
						</tr>
						</cfloop>
					</tbody>
				</table>
				<cfelse>
				<div class="alert alert-warning"><h4>This project doesn't contain any test cases.</h4>Please add one from the Test Cases menu above.</div>
				</cfif>	
			</div>
		</div>				
	</cffunction>
	
	<cffunction name="TestScenarioTestsAndResults" access="remote" output="true">
		<cfargument name="scenarioid" type="numeric" required="true">
		<cfset objData = createObject("component","Data")>
		<cfset arrScenarioData = EntityLoadByPK("TTestScenario",arguments.scenarioid)>
		<cfset qryTestCases = objData.qryTestCaseForScenarios(arrScenarioData.getId())>
		<cfset qryTestCounts = objData.qryTestCaseHistoryForScenarios(arrScenarioData.getId())>
		<cfset qryTestCasesAssigned = objData.qryTestCaseHistoryDataForScenario(arrScenarioData.getId())>
		<div id="scenarioreport">
		<div class="col-xs-9 col-sm-9 col-md-9 col-lg-9"><canvas id="chartcanvas" name="chartcanvas" width="100%" height="300" /></div>
				<div class="col-xs-3 col-sm-3 col-md-3 col-lg-3">
					<cfset totaltests = 0>
					<cfloop query="qryTestcounts">
						<cfset totaltests = totaltests + StatusCount >
					</cfloop>
					<cfloop query="qryTestCounts">
					<p><span class="label #returnBSLabelStyle(Status)#">#StatusCount#&nbsp;#Status#</span><br />#NumberFormat((StatusCount gt 0 AND totaltests gt 0) ? (StatusCount / totaltests) * 100 : 0,"0.0")#% set to #Status#</p>
					</cfloop>
				</div>
				<script type="text/javascript">
					var donutData = [
									<cfloop query="qryTestCounts">
									<cfif StatusCount gt 0>
									{
										title : "#Status#",
										<cfswitch expression="#Status#">
										<cfcase value="Passed">
										color : "##5cb85c",
										</cfcase>
										<cfcase value="Failed">
										color : "##d9534f",
										</cfcase>
										<cfcase value="Untested,Assigned,Created">
										color : "##5bc0de",
										</cfcase>
										<cfcase value="Blocked">
										color : "##777",
										</cfcase>
										<cfcase value="Retest">
										color : "##f0ad4e",
										</cfcase>
										</cfswitch>
										value : #StatusCount#
									}
									<cfif currentRow LT qryTestCounts.RecordCount>,</cfif>
									</cfif>
									</cfloop>
								];
							
							var donutoptions = {
								canvasBorders : false,
								legend : false,
								scaleOverride : false,
								scaleStartValue : null,
								savePng : true,
								savePngOutput : "Save",
								savePngName: "TestsAndResults",
								graphTitle : "Tests and Results",
								savePngBackgroundColor : "white",
								annotateDisplay : true,
								inGraphDataShow: true,
								responsive: true,
								responsiveMaxHeight: 300,
								maintainAspectRatio: false
							};
							var chartObj = new Chart(document.getElementById("chartcanvas").getContext("2d")).Doughnut(donutData,donutoptions);
						</script>
		</div>
	</cffunction>
	
	<cffunction name="TestScenarioActivity" access="remote" output="true">
		<cfargument name="scenarioid" type="numeric" required="true">
		<cfif (!StructKeyExists(SESSION,"Loggedin") || !Session.Loggedin)>
			<cfreturn>
		</cfif>
		<cfstoredproc procedure="PReturnTestResultCountsByScenario">
			<cfprocparam cfsqltype="cf_sql_int" value="#Session.projectid#">
			<cfprocparam cfsqltype="cf_sql_int" value="#arguments.scenarioid#">
			<cfprocresult name="qryCounts" />
		</cfstoredproc>
		<cfscript>
			local.TotalPassedCount = 0;
			local.TotalFailedCount = 0;
			local.TotalUntestedCount = 0;
			local.TotalBlockedCount = 0;
			local.TotalRetestCount = 0;
		</cfscript>
		<cfloop query="qryCounts">
			<cfset local.TotalPassedCount = local.TotalPassedCount + PassedCount />
			<cfset local.TotalFailedCount = local.TotalFailedCount + FailedCount />
			<cfset local.TotalUntestedCount = local.TotalUntestedCount + UntestedCount />
			<cfset local.TotalBlockedCount = local.TotalBlockedCount + BlockedCount />
			<cfset local.TotalRetestCount = local.TotalRetestCount + RetestCount />
			
		</cfloop>
		<cfset local.TotalCount = local.TotalBlockedCount + local.TotalFailedCount + local.TotalPassedCount + local.TotalRetestCount + local.TotalUntestedCount/>
		<cfset local.PassedPercent = (local.TotalCount gt 0) ? (local.TotalPassedCount / local.TotalCount) * 100 : 0 >
		<cfset local.FailedPercent = (local.TotalCount gt 0) ? (local.TotalFailedCount / local.TotalCount) * 100 : 0>
		<cfset local.UntestedPercent = (local.TotalCount gt 0) ?  (local.TotalUntestedCount / local.TotalCount) * 100 : 0>
		<cfset local.BlockedPercent = (local.TotalCount gt 0) ? (local.TotalBlockedCount / local.TotalCount) * 100 : 0>
		<cfset local.RetestPercent = (local.TotalCount gt 0) ? (local.TotalRetestCount / local.TotalCount) * 100 : 0> 
		<div id="scenarioreport">
		<div class="col-xs-9 col-sm-9 col-md-9 col-lg-9"><canvas id="chartcanvas" name="chartcanvas" width="100%" height="300" /></div>
		<div class="col-xs-3 col-sm-3 col-md-3 col-lg-3">
			<p><span class="label label-success">#local.TotalPassedCount#&nbsp;Passed</span><br />#NumberFormat(local.PassedPercent,"0.00")#% set to Passed</p>
			<p><span class="label label-default">#local.TotalBlockedCount#&nbsp;Blocked</span><br />#NumberFormat(local.BlockedPercent,"0.00")#% set to Blocked</p>
			<p><span class="label label-warning">#local.TotalRetestCount#&nbsp;Retest</span><br />#NumberFormat(local.RetestPercent,"0.00")#% set to Retest</p>
			<p><span class="label label-danger">#local.TotalFailedCount#&nbsp;Failed</span><br />#NumberFormat(local.FailedPercent,"0.00")#% set to Failed</p>
			<p><span class="label label-info">#local.TotalUntestedCount#&nbsp;Untested</span><br />#NumberFormat(local.UntestedPercent,"0.00")#% set to Untested</p>
		</div>
		<script type="text/javascript">
			var barData = {
						labels : [#Replace(QuotedValueList(qryCounts.DateTested,","),"/","\/","all")#],
						datasets : [
							{
								title : "Passed",
								strokeColor : "##5cb85c",
								fillColor : "rgba(92, 184, 92, .5)",
								data : [#ValueList(qryCounts.PassedCount,",")#]
							},
							{
								title : "Failed",
								strokeColor : "##d9534f",
								fillColor : "rgba(217, 83, 79, .5)",
							    data : [#ValueList(qryCounts.FailedCount,",")#]
							},
							{
								title : "Untested",
								strokeColor : "##5bc0de",
								fillColor : "rgba(91, 192, 222, .5)",
								data : [#ValueList(qryCounts.UntestedCount,",")#]
							},
							{
								title : "Blocked",
								strokeColor : "##777",
								fillColor : "rgba(119, 119, 119, .5)",
								data : [#ValueList(qryCounts.BlockedCount,",")#]
							},
							{
								title : "Retest",
								strokeColor : "##f0ad4e",
								fillColor : "rgba(240, 173, 78, .5)",
								data : [#ValueList(qryCounts.RetestCount,",")#]
							}
						]
					}
					var options = {
						canvasBorders : false,
						legend : false,
						yAxisMinimumInterval : 1,
						scaleStartValue : 0,
						xAxisLabel : "Date",
						yAxisLabel : "Count",
						savePng : true,
						savePngOutput : "Save",
						savePngName: "Activity",
						savePngBackgroundColor : "white",
						annotateDisplay : true,
						graphTitle: "Activity",
						responsive: true,
						responsiveMaxHeight: 300,
						maintainAspectRatio: false
					};
					var chartObj = new Chart(document.getElementById("chartcanvas").getContext("2d")).Line(barData,options);
					// -->
				</script>
			</div>
	</cffunction>
	
	<cffunction name="TestCaseHub" access="public" output="true">
		<cfargument name="projectid" type="numeric" required="true">
		<cfargument name="addTestCase" type="boolean" required="false" default="false">
		<cfset objData = createObject("component","Data")>
		<cfset qryTestProject = objData.getProject(arguments.projectid)>
		<cfset qryTestCases = objData.qryTestCasesForProject(arguments.projectid)>
		<cfset qryTestCounts = objData.qryTestCaseHistoryDataByProject(arguments.projectid)>
		<cfset arrStatus = EntityLoad("TTestStatus")>
		<script type="text/javascript">
			$(document).ready(function() {
				$(".selectpicker").selectpicker();
				$(document).off('change','##ddluser');
				$(document).on('change','##ddluser',function() {
					alert("test point");
					var testcaseid = $(this).attr("tcid");
					var userid = $(this).val();
					$.ajax({
						url: '/CFTestTrack/cfc/Forms.cfc?method=assignTester',
						type: 'POST',
						data: { testcaseid : testcaseid, testerid : userid }
					}).done(function() {
						$("##featurecontent").removeClass("panel").removeClass("panel-default");
						$("##featurecontent").load("/CFTestTrack/cfc/Dashboard.cfc?method=TestScenarioHub&scenarioid="+#arguments.scenarioid#);
					});
				});
			});
			function onRowSelect(objCheckbox) {
				if ($(objCheckbox).is(":checked")) {
					$("##addLink").removeClass("disabled");
					$("##removeLink").removeClass("disabled");
				} else {
					if ( $("input:checkbox[name=cbxId]").is(":checked") ) {
						$("##addLink").removeClass("disabled");
						$("##removeLink").removeClass("disabled");
					} else {
						$("##addLink").addClass("disabled");
						$("##removeLink").addClass("disabled");
					}
				}
			}
		</script>
		<div class="panel panel-default">
			<div class="panel-heading"><span class="label label-info">#qryTestProject.getAxoSoftID()#</span> #qryTestProject.GetProjectTitle()#
			<!---<div class="btn-group" style="float:right;margin-top:-5px;">
				<a class="btn btn-sm btn-info" href="##">
					<i class="fa fa-bar-chart fa-fw"></i> Scenario Reports</a>
					<a class="btn btn-info btn-sm dropdown-toggle" data-toggle="dropdown" href="##"><span class="fa fa-caret-down"></span></a>
					<ul id="tsreportmentu" class="dropdown-menu">
						<li><a href='##' class='lnkQuickTSReport' reportvalue='TestScenarioTestsAndResults' scenarioid="#arrScenarioData.getId()#"><i class='fa fa-pie-chart fa-fw'></i> Tests and Results</a></li>
						<li><a href='##' class='lnkQuickTSReport' reportvalue='TestScenarioActivity' scenarioid="#arrScenarioData.getId()#"><i class='fa fa-line-chart fa-fw'></i> Activity</a></li>
				</ul></div>--->
			</div>
			<div class="panel-body">
				<!---#TestScenarioTestsAndResults(arguments.scenarioid)#
				---><div class="clearfix"></div>
				<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
					<h4>All Test Cases <small>(#qryTestCases.RecordCount#)</h4>
					<div class="navbar">
						<div class="navbar-inner">
							<ul class="nav navbar-nav navbar-right">
								<li>
									<div class="btn-group">
										<a href="##" id="addLink" class="lnkAddResults btn btn-info btn-xs disabled"><i class="fa fa-plus-square"></i> Update/Add Results</a>
										<a href="##" id="removeLink" class="lnkRemoveTestCases btn btn-info btn-xs disabled"><i class="fa fa-trash-o"></i> Remove Test Case(s)</a>
										<a href="?addTestCase=true" class="btn btn-info btn-xs"><i class="fa fa-plus-square"></i> Add Test Case</a>
									</div>
								</li>
							</ul>
						</div>
					</div>
					<table class="table table-condensed table-striped table-hover">
						<thead>
							<tr>
								<th></th>
								<th>Case ID</th>
								<th>Test Title</th>
								<th>Assigned To</th>
								<th>Status</th>
								<th></th>
							</tr>
						</thead>
						<tbody>
						<cfloop query="qryTestCases">
						<tr>
							<td><input type="checkbox" id="cbxId" name="cbxId" class="cbxTestId" caseid="#id#" onclick="onRowSelect(this);"  /></td>
							<td><h4 style="margin:0"><span class="label label-info">TC#id#</span></h4></td>
							<td>#TestTitle#</td>
							<td><select id='ddluser' class='selectpicker' data-style='btn-primary btn-xs' tcid='#id#'>
									<cfset arrTesters = EntityLoad("TTestTester")>
									<cfloop array="#arrTesters#" index="tester">
										<option value="#tester.getId()#"<cfif tester.getUserName() eq UserName> selected="selected"</cfif>>#tester.getUserName()#</option>
									</cfloop></select></td>
							<td style="width:8%">
								<cfset qryTestStatus = objData.qryGetCurrentTestStatus(id)>
								<!---<select class="form-control selectpicker" caseid="#testcaseid#" data-style="#returnBSLabelStyle(qryTestStatus.Status[1],"btn")# btn-xs">
								<cfloop array="#arrStatus#" index="indstatus">
									<option value="#indstatus.getId()#"<cfif qryTestStatus.Status[1] eq indstatus.getStatus()> selected</cfif>>#indstatus.getStatus()#</option>
								</cfloop>
								</select>--->
								<h4 style="margin:0;"><span class="label #returnBSLabelStyle(qryTestStatus.Status[1],'label')# label-xs">#qryTestStatus.Status[1]#</span></h4>
							</td>
							<td>
								<a href="?edittc=#id#" class="btn btn-xs btn-success">Edit</a>&nbsp;
								<a href="?deletetc=#id#" class="btn btn-xs btn-danger">Delete</a>
							</td>
						</tr>
						</cfloop>
						</tbody>
					</table>						
				</div>
			</div>	
		</div>
	</cffunction>
	
	<cffunction name="TestScenarioHub" access="remote" output="true">
		<cfargument name="scenarioid" type="numeric" required="true">
		<cfif (!StructKeyExists(SESSION,"Loggedin") || !Session.Loggedin)>
			<cfreturn>
		</cfif>
		<cfset objData = createObject("component","Data")>
		<cfset arrScenarioData = EntityLoadByPK("TTestScenario",arguments.scenarioid)>
		<cfset qryTestCases = objData.qryTestCaseForScenarios(arrScenarioData.getId())>
		<cfset qryTestCounts = objData.qryTestCaseHistoryForScenarios(arrScenarioData.getId())>
		<cfset qryTestCasesAssigned = objData.qryTestCasesAssignedScenario(arrScenarioData.getId())>
		<cfset arrStatus = EntityLoad("TTestStatus")>
		<script type="text/javascript">
			$(document).ready(function() {
				$(".selectpicker").selectpicker();
				$(document).off('change','##ddluser');
				$(document).on('change','##ddluser',function() {
					var testcaseid = $(this).attr("tcid");
					var userid = $(this).val();
					$.ajax({
						url: '/CFTestTrack/cfc/Forms.cfc?method=assignTester',
						type: 'POST',
						data: { testcaseid : testcaseid, testerid : userid }
					}).done(function() {
						$("##featurecontent").removeClass("panel").removeClass("panel-default");
						$("##featurecontent").load("/CFTestTrack/cfc/Dashboard.cfc?method=TestScenarioHub&scenarioid="+#arguments.scenarioid#);
					});
				});
			});
			function onRowSelect(objCheckbox) {
				if ($(objCheckbox).is(":checked")) {
					$("##addLink").removeClass("disabled");
					$("##removeLink").removeClass("disabled");
				} else {
					if ( $("input:checkbox[name=cbxId]").is(":checked") ) {
						$("##addLink").removeClass("disabled");
						$("##removeLink").removeClass("disabled");
					} else {
						$("##addLink").addClass("disabled");
						$("##removeLink").addClass("disabled");
					}
				}
			}
		</script>
		<h1 class="page-header">#arrScenarioData.getTestScenario()#</h1>
		<div class="panel panel-default">
			<div class="panel-heading"><span class="label label-info">S#arrScenarioData.getId()#</span> #arrScenarioData.getTestScenario()#
			<div class="btn-group" style="float:right;margin-top:-5px;">
				<a class="btn btn-sm btn-info" href="##">
					<i class="fa fa-bar-chart fa-fw"></i> Scenario Reports</a>
					<a class="btn btn-info btn-sm dropdown-toggle" data-toggle="dropdown" href="##"><span class="fa fa-caret-down"></span></a>
					<ul id="tsreportmentu" class="dropdown-menu">
						<li><a href='##' class='lnkQuickTSReport' reportvalue='TestScenarioTestsAndResults' scenarioid="#arrScenarioData.getId()#"><i class='fa fa-pie-chart fa-fw'></i> Tests and Results</a></li>
						<li><a href='##' class='lnkQuickTSReport' reportvalue='TestScenarioActivity' scenarioid="#arrScenarioData.getId()#"><i class='fa fa-line-chart fa-fw'></i> Activity</a></li>
				</ul></div></div>
			<div class="panel-body">
				#TestScenarioTestsAndResults(arguments.scenarioid)#
				<div class="clearfix"></div>
				<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
					<h4>All Test Cases <small>(#qryTestCases.RecordCount#)</h4>
					<div class="navbar">
						<div class="navbar-inner">
							<ul class="nav navbar-nav navbar-right">
								<li>
									<div class="btn-group">
										<a href="##" id="addLink" class="lnkAddResults btn btn-info btn-xs disabled" scenarioid="#arguments.scenarioid#"><i class="fa fa-plus-square"></i> Update/Add Results</a>
										<a href="##" id="removeLink" class="lnkRemoveTestCases btn btn-info btn-xs disabled" scenarioid="#arguments.scenarioid#"><i class="fa fa-trash-o"></i> Remove Test Case(s)</a>
										<a href="##" class="lnkAddTestCaseToScenario btn btn-info btn-xs" scenarioid="#arguments.scenarioid#"><i class="fa fa-plus-square"></i> Add Test Case</a>
									</div>
								</li>
							</ul>
						</div>
					</div>
					<table class="table table-condensed table-striped table-hover">
						<thead>
							<tr>
								<th></th>
								<th>Case ID</th>
								<th>Test Title</th>
								<th>Assigned To</th>
								<th>Status</th>
							</tr>
						</thead>
						<tbody>
						<cfloop query="qryTestCases">
						<tr>
							<td><input type="checkbox" id="cbxId" name="cbxId" class="cbxTestId" caseid="#testcaseid#" onclick="onRowSelect(this);"  /></td>
							<td><span class="label label-info">TC#testcaseid#</span></td>
							<td>#TestTitle#</td>
							<td><select id='ddluser' class='selectpicker' data-style='btn-primary btn-xs' tcid='#testcaseid#'>
									<cfset arrTesters = EntityLoad("TTestTester")>
									<cfloop array="#arrTesters#" index="tester">
										<option value="#tester.getId()#"<cfif tester.getUserName() eq UserName> selected="selected"</cfif>>#tester.getUserName()#</option>
									</cfloop></select></td>
							<td style="width:8%">
								<cfset qryTestStatus = objData.qryGetCurrentTestStatus(testcaseid)>
								<!---<select class="form-control selectpicker" caseid="#testcaseid#" data-style="#returnBSLabelStyle(qryTestStatus.Status[1],"btn")# btn-xs">
								<cfloop array="#arrStatus#" index="indstatus">
									<option value="#indstatus.getId()#"<cfif qryTestStatus.Status[1] eq indstatus.getStatus()> selected</cfif>>#indstatus.getStatus()#</option>
								</cfloop>
								</select>--->
								<span class="label #returnBSLabelStyle(qryTestStatus.Status[1],'label')# label-xs">#qryTestStatus.Status[1]#</span>
							</td>
						</tr>
						</cfloop>
						</tbody>
					</table>						
				</div>
			</div>	
		</div>
	</cffunction>
		
	<cffunction name="assignedTestsGrid" access="remote" output="true">
		<cfargument name="userid" type="numeric" required="true">
		<cfargument name="page" type="numeric" required="true" default="1">
		<cfargument name="pageSize" type="numeric" required="true" default="10">
		<cfif (!StructKeyExists(SESSION,"Loggedin") || !Session.Loggedin)>
			<cfreturn>
		</cfif>
		<cfscript>
			objData = createObject("component","Data");
			arrTests = objData.getAssignedTestCasesByTesterId(arguments.userid);
			local.testCount = ArrayLen(arrTests);
			arrTestsForGrid =  ormExecuteQuery("FROM TTestCaseHistory WHERE TesterID = :testerid AND Action = 'Assigned' AND DateActionClosed IS NULL",{testerid=arguments.userid},{maxResults=arguments.pageSize,offset=arguments.page-1});
			local.pageCount = Round(local.testCount / arguments.pageSize);
		</cfscript>
		<div class="panel panel-default">
		<div class="panel-heading">Tests Assigned To You</div>
		<div class="panel-body">
		<cfif local.pageCount gt 1>
			<cfset local.nav='<div id="paging_nav">'>
			<cfif arguments.page gt 1><cfset local.nav &= '<a href="" id="paging_nav_previous">'></cfif>
			<cfset local.nav &= 'Previous'>
			<cfif arguments.page gt 1><cfset local.nav &= '</a>'></cfif>
			<cfloop from="1" to="#local.pageCount#" index="index">
				<cfset local.nav &= '<a href="" class="paging_nav_a">' & #index# >
			</cfloop>
			<cfif arguments.page lt local.pageCount><cfset local.nav &= '<a href="" id="paging_nav_next">'></cfif>
			<cfset local.nav &= "Next">
			<cfif arguments.page lt local.pageCount><cfset local.nav &= "</a>"></cfif>
			<cfset local.nav &="</div>">
			<cfoutput>#local.nav#</cfoutput>
		</cfif>
		<table class="table table-striped">
		<tbody>
			
		<cfloop array="#arrTestsForGrid#" index="test">
			<cfquery dbtype="hql" name="case">
				FROM TTestCase t WHERE t.id = <cfqueryparam value="#test.getCaseID()#">
			</cfquery>
			<cfloop array="#case#" index="i">
				<cfquery dbtype="hql" name="latestresult" ormoptions=#{maxResults=1}#>
					FROM TTestResult as a
					WHERE a.TestCaseID = <cfqueryparam value="#i.getID()#">
					ORDER BY a.id DESC
				</cfquery>
				
				<cfoutput>
					<tr>
					<td class="right">
						<span class="label #returnBSLabelStyle(latestresult[1].getTTestStatus().getStatus())#">#latestresult[1].getTTestStatus().getStatus()#</span>
					</td>
					<td>#i.getTestTitle()#</td>
					<td>Last tested by <span style="font-weight:bold;">#latestresult[1].getTTestTester().getUserName()#</span></td>
					</tr>
				</cfoutput>
			</cfloop>
		</cfloop>
		</tbody>
		</table>
		</div>
		</div>
	</cffunction>

	<cffunction name="mostRecentTests" access="remote" output="true">
		<cfif (!StructKeyExists(SESSION,"Loggedin") || !Session.Loggedin)>
			<cfreturn>
		</cfif>
		<cfif (!StructKeyExists(SESSION,"ProjectID"))>
			<cfreturn>
		</cfif>
		<cfquery name="recenttests">
			SELECT TOP 10 id, Status, TestTitle, UserName, DateTest FROM (
				SELECT TOP 20 a.id, c.Status, a.TestTitle, d.UserName, b.DateTested as DateTest
				FROM TTestCase a
				INNER JOIN TTestResult b on a.id = b.TestCaseId
				INNER JOIN TTestStatus c on b.StatusId = c.id
				INNER JOIN TTestTester d on b.TesterID = d.id
				WHERE a.ProjectID = <cfqueryparam value="#Session.ProjectID#">
				ORDER By b.DateTested DESC
				UNION ALL
				SELECT TOP 20 a.id, b.Action as Status, a.TestTitle, d.UserName, b.DateOfAction as DateTest
				FROM TTestCase a
				INNER JOIN TTestCaseHistory b on a.id = b.CaseId
				INNER JOIN TTestTester d on b.TesterID = d.Id
				WHERE a.ProjectID = <cfqueryparam value="#Session.ProjectID#">
				ORDER BY b.DateOfAction
			) stuff 
			ORDER BY DateTest
		</cfquery>
		
		<div class="clearfix"></div>	
		<div id="activitypanel" class="panel panel-default">
		<div class="panel-heading">Activity</div>
		<div class="panel-body">
		<table class="table table-striped table-condensed">
			<thead>
				<tr>
					<th>Test Status</th>
					<th>Test Title</th>
					<th>Last Tester</th>
					<th></th>
				</tr>
			</thead>
			<tbody>
		<cfloop query="recenttests">
			<!---<cfquery name="caseinfo" dbtype="hql" ormoptions=#{maxResults=1}#>
				FROM TTestCase WHERE id = <cfqueryparam value="#id#">
			</cfquery>--->
			<tr><cfoutput>
				<td class="right"><h4 style="margin:0px;"><span class="label #returnBSLabelStyle(status)# label-xs">#Status#</span></h4></td>
				<td>#TestTitle#</td>
				<td>Tested by/Assigned To <span style="font-weight: bold;">#UserName#</span></td>
				<td><a href="##" class="testcaseeditlink btn btn-default btn-xs" editid="#id#"><i class="fa fa-pencil"></i> Edit</a></td>
				</cfoutput>
			</tr>
		</cfloop>
			</tbody>
		</table>
		</div>
		</div>
	</cffunction>
	
	<cffunction name="getDeletedProjectData" access="remote" output="true">
		
	</cffunction>

	<cffunction name="getMilestones" access="public" output="true">
		<cfargument name="projectid" required="true">
		<cfif (!StructKeyExists(SESSION,"Loggedin") || !Session.Loggedin)>
			<cfreturn>
		</cfif>
		<cfquery name="qryMilestones" dbtype="hql" ormoptions=#{maxresults=5}#>
			FROM TTestMilestones
			WHERE ProjectID = <cfqueryparam value="#arguments.projectid#">
			AND (DueOn >= <cfqueryparam value="#DateFormat(now(),'yyyy-mm-dd')#"> OR Closed = 0)
			ORDER By DueOn ASC
		</cfquery>
		<div id="panelmilestones">
			<div class="panel panel-default">
				<div class="panel-heading">Top 5 Milestones</div>
				<div class="panel-body">
					<cfif ArrayLen(qryMilestones) gt 0>
						<table class="table table-striped table-condensed">
						<thead>
							<th>Milestone</th>
							<th>Due On</th>
							<th></th>
						</thead>
						<tbody>
							<cfloop array="#qryMilestones#" index="milestone">
							<cfif milestone.getDueOn() LT Now()>
								<tr class="highlight" style="color:red;font-weight:bold;">
							<cfelse>
							<tr>
							</cfif>
								<td>#milestone.getMilestone()#</td>
								<td>#DateFormat(milestone.getDueOn(),"MM/DD/YYYY")#</td>
								<td><a href="##" class="lnkEditMilestone btn btn-default btn-xs" milestoneid="#milestone.getId()#"><i class="fa fa-pencil"></i> Edit</a>&nbsp;&nbsp;<a href="##" class="lnkDeleteMilestone btn btn-danger btn-xs" milestoneid="#milestone.getId()#"><i class="fa fa-trash"></i> Delete</a></td>
							</tr>
							</cfloop>
						</tbody>
					</table>
					<cfelse>
						<div class="alert alert-warning"><h4>This project doesn't contain any milestones.</h4>Please add one from the Milestones menu above.</div>
					</cfif>
				</div>
				<div class="panel-footer"><div class="btn-group"><a href="##" class="lnkAddMilestone btn btn-info btn-sm"><i class="fa fa-plus-square"></i> Add Milestone</a><a href="##" class="lnkViewMilestones btn btn-info btn-sm"><i class="fa fa-list"></i> View All</a></div></div>
			</div>
		</div>			
	</cffunction>
	
	<cffunction name="getLinks" access="public" output="true">
		<div id="linkspanel" class='panel panel-default'><div class='panel-heading'><i class='fa fa-code'></i> Links</span></div>
		<div class='panel-body'>
		<cfset arrLinks = entityload("TTestLinks")>
		<cfif ArrayLen(arrLinks) gt 0>
			<table class='table table-striped'><tbody>
			<cfloop array="#arrLinks#" index="link">	
				<tr>
					<td><a href='#link.getLinkHref()#' style='margin-bottom:5px;text-decoration:none;'><i class='fa fa-link'></i> #link.getLinkDesc()#</a></td>
				</tr>
			</cfloop>
		</tbody></table>
		<cfelse>
		<div class="alert alert-warning"><h4>No links.</h4>Administrators may add links from settings.</div>
		</cfif></div></div>
	</cffunction>
	
	<cffunction name="getTodos" access="remote" output="true">
		<cfstoredproc procedure="PTodos">
			<!---<cfprocparam cfsqltype="CF_SQL_INTEGER" value="#Session.UserIDInt#">--->
			<cfprocresult name="qryTodos" />
		</cfstoredproc>
		<div id='todopanel' class="panel panel-default"><div class="panel-heading"><i class="fa fa-check-square-o"></i> Todos</div>
			<div class='panel-body'>
				<cfif qryTodos.RecordCount gt 0>
				<table id='todotable' class='table table-striped'>
					<tbody>
						<cfloop query="qryTodos">
							<tr><td>#Section#</td><td>(#ItemCount#)</td></tr>
						</cfloop>
					</tbody>
				</table>
				<cfelse>
				<div class="alert alert-warning"><h4>No todos.</h4>Either consider yourself lucky or find something to do.</div>
				</cfif>
			</div>
		</div>
	</cffunction>
	
	<cffunction name="getCreateReports" access="remote" output="true">
			<script type="text/javascript">
				$(document).ready(function() {
					$('[data-toggle="tooltip"]').tooltip();
				});
			</script>
				<li><a href="##"><i class="fa fa-bars fa-fw"> </i> Create Reports<span class="fa arrow"></span></a>
				<ul class="nav nav-second-level">
				<cfif Application.AxoSoftIntegration eq "true">
					<li><a href="##" class="lnkCreateReport" reporttype="AllOpenItems" data-toggle="tooltip" data-placement="right" title="Shows all open AxoSoft items."><i class="fa fa-plus-circle" style="color: green;"></i> All Open Items</a></li>
					<li><a href="##" class="lnkCreateReport" reporttype="ReadyForProduction" data-toggle="tooltip" data-placement="right" title="Shows all AxoSoft items ready for production."><i class="fa fa-plus-circle" style="color: green;"></i> Ready For Production</a></li>
					<li><a href="##" class="lnkCreateReport" reporttype="ClientAcceptance" data-toggle="tooltip" data-placement="right" title="Client acceptance items report."><i class="fa fa-plus-circle" style="color: green;"></i> Client Acceptance</a></li>
					
				</cfif>
					<li><a href="##" class="lnkCreateReport" reporttype="Activity" data-toggle="tooltip" data-placement="right" title="Shows a summary of new and updated test cases."><i class="fa fa-plus-circle" style="color:green;"></i> Activity</a></li>
					<li><a href="##" class="lnkCreateReport" reporttype="ExecutionList" data-toggle="tooltip" data-placement="right" title="Displays Execution data for test scenarios."><i class="fa fa-plus-circle" style="color:green;"></i> Execution List</a></li>
					<li><a href="##" class="lnkCreateReport" reporttype="ProblemTestCases" data-toggle="tooltip" data-placement="right" title="Displays problem test cases for this project."><i class="fa fa-plus-circle" style="color:green;"></i> Problem Test Cases</a></li>
					<li><a href="##" class="lnkCreateReport" reporttype="DefectsSummary" data-toggle="tooltip" data-placement="right" title="Displays defect summary for selected test scenarios."><i class="fa fa-plus-circle" style="color:green;"></i> Defect Summary</a></li>
					<li><a href="##" class="lnkCreateReport" reporttype="TestCaseDefectsSummary" data-toggle="tooltip" data-placement="right" title="Displays test case defect summaries for project."><i class="fa fa-plus-circle" style="color:green;"></i> Summary for Test Cases</a></li>
					<li><a><i class="fa fa-plus-circle" style="color:green;"></i> Case Comparison</a></li>
					<li><a><i class="fa fa-plus-circle" style="color:green;"></i> Reference Comparison</a></li>
					<li><a><i class="fa fa-plus-circle" style="color:green;"></i> Property Distribution</a></li>
					<li><a><i class="fa fa-plus-circle" style="color:green;"></i> Milestone Summary</a></li>
					<li><a><i class="fa fa-plus-circle" style="color:green;"></i> Scenario Summary</a></li>
					<li><a><i class="fa fa-plus-circle" style="color:green;"></i> Project Summary</a></li>
					<li><a><i class="fa fa-plus-circle" style="color:green;"></i> User Workload Summary</a></li>
				</ul>
				<lia>
	</cffunction>
	
	<!--- JSON and single value functions --->
		
	<cffunction name="TodosBySection" access="remote" returnformat="JSON" returntype="string">
		<cfstoredproc procedure="PTodos">
			<!--cfprocparam cfsqltype="CF_SQL_INTEGER" value="#Session.UserIDInt#">-->
			<cfprocresult name="qryTodos" />
		</cfstoredproc>
		<cfreturn serializeJSON(qryTodos) />
	</cffunction>
	
	<cffunction name="MilestonesJSON" access="remote" returnformat="JSON" returntype="string">
		<cfscript>
			objData = CreateObject("component","Data");
			arrMilestones = objData.getAllMilestones();
			return serializeJSON(arrMilestones);
		</cfscript>
	</cffunction>
	
	<cffunction name="LinksJSON" access="remote" returnformat="JSON" returntype="string">
		<cfscript>
			objData = createObject("component","Data");
			arrLinks = objData.getAllLinks();
			return serializeJSON(arrLinks);
		</cfscript>
	</cffunction>
	
	<cffunction name="allProjectsCount" access="remote" returnformat="JSON" returntype="string">
		<cfscript>
			objData = createObject("component","Data");
			arrProjects = objData.getAllProjects();
			returnData = StructNew();
			returnData["TotalProjects"] = IsNull(ArrayLen(arrProjects)) ? 0 : ArrayLen(arrProjects);
		</cfscript>
		<!--- active projects --->
		<cfquery name="qryActiveProjects" dbtype="hql">
			FROM TTestProject
			WHERE ProjectStartDate <= <cfqueryparam value="#DateFormat(now(),'yyyy-mm-dd')#" >
			AND Closed = 0
		</cfquery>
		<cfset returnData["ActiveProjects"] = arrayLen(qryActiveProjects) >
		<!--- closed projects --->
		<cfquery name="qryCompletedProjects" dbtype="hql">
			FROM TTestProject
			WHERE Closed = 1
		</cfquery>
		<cfset returnData["CompletedProjects"] = arrayLen(qryCompletedProjects)>
		<cfreturn serializeJSON(returnData)>
	</cffunction>
	
	<cffunction name="allProjectsJSON" access="remote" returnformat="JSON" returntype="string">
		<cfargument name="includeInactiveProjects" type="boolean" required="false" default="false">
		<cfif (!StructKeyExists(SESSION,"Loggedin") || !Session.Loggedin)>
			<cfreturn>
		</cfif>
		<cfquery name="qryActiveProjects" dbtype="hql">
			FROM TTestProject
			<CFIF !includeInactiveProjects>WHERE Closed = 0</CFIF>
			ORDER BY id
		</cfquery>
		<cfreturn serializeJSON(qryActiveProjects)>
	</cffunction>
	
	<cffunction name="assignedTestsCount" access="remote" returntype="numeric">
		<cfargument name="userid" type="numeric">
		<cfscript>
			objData = createObject("component","Data");
			arrTests = objData.getAssignedTestCasesByTesterId(arguments.userid);
			return ArrayLen(arrTests);
		</cfscript>
	</cffunction>
	
	<cffunction name="setSessionProject" access="remote" returntype="void" httpmethod="POST">
		<cfargument name="projectid" required="true" type="numeric">		
		<cfif (!StructKeyExists(SESSION,"Loggedin") || !Session.Loggedin)>
			<cfreturn>
		</cfif>
		<cfset Session.ProjectID = arguments.projectid>
	</cffunction>
	
	<cffunction name="removeSessionProject" access="remote" returntype="void" httpmethod="post">
		<cfif (!StructKeyExists(Session,"LoggedIn") || !Session.Loggedin)>
			<cfreturn>
		</cfif>
		<cfset StructDelete(Session,"ProjectID")>
	</cffunction>
	
	<cffunction name="returnBSLabelStyle" access="private" returntype="string">
		<cfargument name="labelExpression" required="true">
		<cfargument name="element" required="false" default="label">
		<cfset local.labelstyle = "">
		<cfswitch expression="#arguments.labelExpression#">
				<cfcase value="Passed">
					<cfset local.labelstyle = "#arguments.element#-success">
				</cfcase>
				<cfcase value="Failed">
					<cfset local.labelstyle = "#arguments.element#-danger">
				</cfcase>
				<cfcase value="Blocked">
					<cfset local.labelstyle = "#arguments.element#-default">
				</cfcase>
				<cfcase value="Untested,Assigned">
					<cfset local.labelstyle = "#arguments.element#-info">
				</cfcase>
				<cfcase value="Retest">
					<cfset local.labelstyle = "#arguments.element#-warning">
				</cfcase>
				<cfdefaultcase>
					<cfset local.labelstyle = "#arguments.element#-default">
				</cfdefaultcase>
			</cfswitch>
		<cfreturn local.labelstyle>
	</cffunction>
	
	<cffunction name="checkLoggedIn" access="remote" returntype="String" returnformat="JSON">
		<cfset x = structnew()>
		<cfif (!StructKeyExists(SESSION,"Loggedin") || !Session.Loggedin)>
			<cfset x.loggedin = false>
		<cfelse>
			<Cfset x.loggedin = true>
		</cfif>
		<cfreturn serializeJSON(x)>
	</cffunction>
</cfcomponent>