<cfcomponent>

	<cffunction name="getAxoSoftToken" access="public">
		<cfif Application.AxoSoftAuthentication eq "Authorization">
			<cflocation url="#Application.AxoSoftURL#auth?response_type=code&client_id=#Application.AxoSoftClient_Id#&redirect_uri=#Application.AxoSoftRedirectURI#&scope=read%20write" addtoken="false">
		</cfif>
	</cffunction>
	
	<cffunction name="getIncidents" access="public">
		<cfargument name="access_token" required="true">
		<cfhttp url="#Application.AxoSoftURL#api/v2/incidents/?access_token=#arguments.access_token#" method="get" result="httpResult" />
		<cfreturn DeSerializeJSON(httpResult.fileContent) />
	</cffunction>
	
	<cffunction name="getProjects" access="public">
		<cfargument name="access_token" required="true">
		<cfhttp url="#Application.AxoSoftURL#api/v2/projects/?access_token=#arguments.access_token#" method="get" result="httpResult" />
		<cfreturn DeserializeJSON(httpResult.fileContent) />
	</cffunction>
	
	<cffunction name="getWorkflows" access="public">
		<cfargument name="access_token" required="true">
		<cfhttp url="#Application.AxoSoftURL#api/v2/workflows/?access_token=#arguments.access_token#" method="get" result="httpResult" />
		<cfreturn DeserializeJSON(httpResult.fileContent) />
	</cffunction>
	
	<cffunction name="getCustomers" access="public">
		<cfargument name="access_token" required="true">
		<cfhttp url="#Application.AxoSoftURL#api/v2/customers/?access_token=#arguments.access_token#" method="get" result="httpResult" />
		<cfreturn DeserializeJSON(httpResult.fileContent) />
	</cffunction>

	<cffunction name="getContacts" access="public">
		<cfargument name="access_token" required="true">
		<cfhttp url="#Application.AxoSoftURL#api/v2/contacts/?access_token=#arguments.access_token#" method="get" result="httpResult" />
		<cfreturn DeserializeJSON(httpResult.fileContent) />
	</cffunction>
	
	<cffunction name="getDefects" access="public">
		<cfargument name="access_token" required="true">
		<cfhttp url="#Application.AxoSoftURL#api/v2/defects/?access_token=#arguments.access_token#" method="get" result="httpResult" />
		<cfreturn DeserializeJSON(httpResult.fileContent) />
	</cffunction>
	
	<cffunction name="getDefect" access="public">
		<cfargument name="access_token" required="true">
		<cfargument name="defectid" required="true">
		<cfhttp url="#Application.AxoSoftURL#api/v2/defects/#arguments.defectid#?access_token=#arguments.access_token#" method="get" result="httpResult" />
		<cfreturn DeserializeJSON(httpResult.fileContent) />
	</cffunction>
	
	<cffunction name="getUsers" access="public">
		<cfargument name="access_token" required="true">
		<cfhttp url="#Application.AxoSoftURL#api/v2/users/?access_token=#arguments.access_token#" method="get" result="httpResult" />
		<cfreturn DeserializeJSON(httpResult.fileContent) />
	</cffunction>
	
	<cffunction name="addEmail" access="public" output="true">
		<cfargument name="access_token">
		<cfset objemail = { "subject" = "Test", "body" = "test", "from" = "brian.kresge@cornerstoneoperations.com", to="brian.kresge@cornerstoneoperations.com", "email_type" = "text", "item" = { "id" =  249, "type" = "defects" }}>
		<cfhttp method="POST" url="#Application.AxoSoftURL#api/v2/emails" result="httpResult">
			<cfhttpparam type="header" name="Content-Type" value="application/json" />
			<cfhttpparam type="header" name="X-Authorization" value="Bearer #arguments.access_token#" />
			<cfhttpparam type="body" value="#serializeJSON(objemail)#" />
			
		</cfhttp>
		<cfdump var="#serializeJSON(objemail)#">
		<cfdump var="#httpResult#">
	</cffunction>
	
	<cffunction name="defectNotification" access="public" output="true">
		<cfargument name="access_token">
		<cfset objnot = { "user_ids" = "[1103]" }>
		<cfhttp method="POST" url="#Application.AxoSoftURL#api/v2/defects/249/notifications" result="httpResult">
			<cfhttpparam type="header" name="Content-Type" value="application/json" />
			<cfhttpparam type="header" name="X-Authorization" value="Bearer #arguments.access_token#" />
			<cfhttpparam type="body" value="#serializeJSON(objnot)#" />
		</cfhttp>
		<cfdump var="#serializeJSON(objnot)#">
		<cfdump var="#httpResult#">
	</cffunction>
	
	<cffunction name="addDefect" access="public">
		<cfargument name="access_token">
		<cfargument name="defectname">
		<cfargument name="defectdescription">
		<cfargument name="defectnotes">
		<cfargument name="replication_procedures">
		<cfargument name="reported_by">
		<cfargument name="project">
		<cfset item = { "item" = { "reported date" = "#Now()#", "percent_complete" = 0, "archived" = false, "publicly_viewable" = false, "completiondate" = "", "due_date" = "", "description" = "#arguments.defectdescription#", "name" = "#arguments.defectname#", "notes" = "#arguments.defectnotes#", "project" = { "id" = arguments.project } } }>
		<cfhttp method="POST" url="#Application.AxoSoftURL#api/v2/defects" result="httpResult">
			<cfhttpparam type="header" name="Content-Type" value="application/json" />
			<cfhttpparam type="header" name="X-Authorization" value="Bearer #arguments.access_token#" />
			<cfhttpparam type="body" value="#serializeJSON(item)#" />
			
		</cfhttp>
		<cfreturn DeserializeJSON(httpResult.fileContent) />
	</cffunction>
		

</cfcomponent>