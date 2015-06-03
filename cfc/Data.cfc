component
{
	public array function getAllProjects()
	{
		arrProjects = EntityLoad("TTestProject");
		return arrProjects;
	}
	
	public db.TTestProject function getProject(id) {
		project = entityLoad("TTestProject",id,true);
		return project;
	}
	
	public void function deleteProject(id) {
		project = getProject(id);
		EntityDelete(project);
	}
	
	public void function deleteMilestone(id) {
		milestone = getMilestone(id);
		EntityDelete(milestone);
	}
	
	public db.TTestScenario function getScenario(id) {
		scenario = EntityLoad("TTestScenario",id, true);
		return scenario;
	}
	public void function deleteScenario(id) {
		scenario = getScenario(id);
		EntityDelete(scenario);
	}
	
	public void function saveProject(db.TTestProject tp)
	{
		entitySave(arguments.tp);
	}
	
	public db.TTestMilestones function getMilestone(id) {
		milestone = entityLoad("TTestMilestones",id,true);
		return milestone;
	}
	
	public array function getAllTestCases()
	{
		arrTestCases = EntityLoad("TTestCase");
		return arrTestCases;
	}
	
	public array function getTestCasesByProject(projectid)
	{
		arrTestCases = EntityLoad("TTestCase",{ProjectID=arguments.projectid});
		return arrTestCases;
	}
	
	public void function deleteTestCase(id) {
		testcase = getTestCase(id);
		EntityDelete(testcase);
	}
	
	public db.TTestCase function getTestCase(id) {
		testcase = entityLoad("TTestCase",id,true);
		return testcase;
	}
	
	public array function getAssignedTestCasesByTesterId(id) {
		arrTestCases = ormExecuteQuery("FROM TTestCaseHistory WHERE TesterID = :testerid AND Action = 'Assigned' AND DateActionClosed IS NULL",{testerid=arguments.id});
		return arrTestCases;
	}
	
	public void function saveTestCase(db.TTestCase tc)
	{
		entitySave(arguments.tc);
	}
	
	public array function getAllStatuses()
	{
		statuses = entityLoad("TTestStatus");
		return statuses;
	}
	
	public array function getAllTesters()
	{
		testers = entityLoad("TTestTester");
		return testers;
	}
	
	public array function getAllTestCaseHistory()
	{
		history = entityLoad("TTestCaseHistory");
		return history;
	}
	
	public array function getTestCaseHistoryByTestCase(id) {
		history = entityLoad("TTestCaseHistory",{CaseId = arguments.id},false);
		return history;
	}
	
	public query function qryTestCaseHistoryByTestCase(id) {
		arrHistory = getTestCaseHistoryByTestCase(arguments.id);
		return EntityToQuery(arrHistory);
	}
	
	public array function getAllMilestones() 
	{
		milestones = entityLoad("TTestMilestones");
		return milestones;
	}
	public array function getAllLinks()
	{
		links = entityLoad("TTestLinks");
		return links;
	}
	public query function qryTestCaseForScenarios(scenarioid)
	{
		QueryHistory = new query();
		QueryHistory.setName("getTestCaseHistory");
		QueryHistory.addParam(name="scenarioid",value=arguments.scenarioid,cfsqltype="cf_sql_int");
		qryResult = QueryHistory.execute(sql="SELECT a.id as TestCaseId, a.TestTitle, b.DateOfAction, c.UserName, b.DateActionClosed" &
				" FROM TTestCaseHistory b INNER JOIN TTestCase a ON a.id = b.CaseId INNER JOIN TTestTester c on b.TesterID = c.id INNER JOIN TTestScenarioCases d ON a.id = d.CaseId" &
				" WHERE d.ScenarioId = :scenarioid and b.DateActionClosed IS NULL");
		return qryResult.getResult();
	}
	public query function qryTestCaseHistoryForScenarios(scenarioid) {
		QueryHistory = new query();
		QueryHistory.setName("getTestCaseHistory");
		QueryHistory.addParam(name="scenarioid",value=arguments.scenarioid,cfsqltype="cf_sql_int");
		qryResult = QueryHistory.execute(sql="SELECT id,Status,Sum(StatusCount) as StatusCount FROM ( Select TTestStatus.id, Status, ISNULL(Count(a.id),0) as StatusCount FROM TTestStatus LEFT JOIN ( SELECT b.id, b.[Action] FROM TTestCaseHistory b INNER JOIN TTestScenarioCases c on b.CaseId = c.CaseId WHERE c.ScenarioId = :scenarioid and b.DateActionClosed is null ) a ON a.Action = TTestStatus.Status GROUP BY TTestStatus.id, Status  UNION ALL SELECT 1 as id,(CASE WHEN [Action] IN ('Created','Assigned') THEN 'Untested' END) as Status, ISNULL(Count(TTestCaseHistory.id),0) as StatusCount FROM TTestCaseHistory INNER JOIN TTestScenarioCases on TTestScenarioCases.CaseID = TTestCaseHistory.CaseID WHERE ScenarioId = :scenarioid AND [Action] IN ('Created','Assigned') AND DateActionClosed IS NULL GROUP BY [Action] ) DERIVED GROUP BY id, Status");
		return qryResult.getResult();
	}
	public query function qryTestCaseHistoryDataForScenario(scenarioid) {
		qryNew = new query();
		qryNew.setName("getTestCaseHistory");
		qryNew.addParam(name="scenarioid",value=arguments.scenarioid,cfsqltype="cf_sql_int");
		qryResult = qryNew.execute(sql="SELECT DISTINCT d.TestTitle, a.TestCaseId, a.DateTested, e.Status, c.UserName FROM TTestResult a " &
										"INNER JOIN TTestScenarioCases b on a.TestCaseId = b.CaseId " &
										"INNER JOIN TTestTester c on a.TesterID = c.id " &
										"INNER JOIN TTestCase d on a.TestCaseId = d.id " &
										"INNER JOIN TTestStatus e on a.StatusID = e.id " &
										"WHERE b.ScenarioId = :scenarioid");
		return qryResult.getResult();
	}
	public query function qryTestCaseHistoryAllForScenario(scenarioid) {
		qrynew = new query();
		qrynew.setName("getTestCaseHistory");
		qrynew.addParam(name="scenarioid",value=arguments.scenarioid,cfsqltype="cf_sql_int");
		qryResult = qrynew.execute(sql="SELECT d.TestTitle, e.Status, b.UserName, a.DateTested " &
									   "FROM TTestResult a " &
									   "INNER JOIN TTestTester b ON a.TesterID = b.id " &
									   "INNER JOIN TTestScenarioCases c ON a.TestCaseId = c.CaseId " &
									   "INNER JOIN TTestCase d on a.TestCaseId = d.id " &
									   "INNER JOIN TTestStatus e on a.StatusID = e.id " &
									   "WHERE c.ScenarioId = :scenarioid " &
									   "AND DateTested BETWEEN DATEADD(DAY,1,GETDATE()) AND DATEADD(DAY,-14,GETDATE()) " &
									   "ORDER BY TestTitle, DateTested");
		return qryResult.getResult();
	}
	public query function qryTestCasesAssignedScenario(scenarioid) {
		qryNew = new query();
		qryNew.setName("getScenarioTestCases");
		qryNew.addParam(name="scenarioid",value=arguments.scenarioid,cfsqltype="cf_sql_int");
		qryResult = qryNew.execute(sql="SELECT b.TestTitle, c.DateOfAction, d.UserName FROM TTestScenarioCases a " &
										"INNER JOIN TTestCase b ON b.id = a.CaseId " &
										"INNER JOIN TTestCaseHistory c on c.CaseID = a.CaseId " &
										"INNER JOIN TTestTester d on d.id = c.TesterID " &
										"WHERE a.ScenarioId = :scenarioid AND c.Action = 'Assigned'");
		return qryResult.getResult();
	}
	public query function qryGetCurrentTestStatus(caseid) {
		qryNew = new query();
		qryNew.setName("getCaseStatus");
		qryNew.addParam(name="caseid",value=arguments.caseid,cfsqltype="cf_sql_int");
		qryResult = qryNew.execute(sql="SELECT ISNULL(d.Status,'Assigned') as Status FROM TTestCase a " &
				"LEFT JOIN (SELECT TOP 1 c.TestCaseId, b.Status FROM TTestResult c INNER JOIN TTestStatus b on b.id = c.StatusID WHERE c.TestCaseId = :caseid ORDER BY c.id DESC) d ON d.TestCaseId = a.id " &
				"WHERE a.id = :caseid");
		return qryResult.getResult();
	}
}