<%@ page import="java.util.*,
                 org.jivesoftware.openfire.XMPPServer,
                 org.jivesoftware.openfire.group.*,
                 org.jivesoftware.openfire.user.*,
                 berlin.kleinschmit.openfire.plugin.SlackRedirectPlugin,
                 org.jivesoftware.util.*"
%>
<%@ page import="java.util.regex.Pattern"%>

<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jstl/fmt_rt" prefix="fmt" %>

<%
    boolean save = request.getParameter("save") != null;
    boolean success = request.getParameter("success") != null;
    
    String userGroup = ParamUtils.getParameter(request, "group");
    
    //get handle to plugin
	SlackRedirectPlugin plugin = (SlackRedirectPlugin) XMPPServer.getInstance().getPluginManager().getPlugin("slack");

    //input validation
    Map<String, String> errors = new HashMap<String, String>();
    if (save) {
    	if (userGroup == null) {
    		errors.put("missingUserGroup", "missingUserGroup");
    	} else {
    		try {
    			GroupManager.getInstance().getGroup(userGroup);
    		} catch (GroupNotFoundException gnfe) {
	    		errors.put("userGroupNotFound", "userGroupNotFound");
    		}
    	}
    } else {
    	
    }
    
    if (errors.size() == 0) {
    	userGroup = plugin.getGroupName();
    }
%>

<html>
	<head>
		<title>Slack Redirector Settings</title>
        <meta name="pageID" content="slack-settings"/>
	</head>
	<body>

<p>
Use the form below to edit Slack redirector settings.<br>
</p>

<%  if (success) { %>

    <div class="jive-success">
    <table cellpadding="0" cellspacing="0" border="0">
    <tbody>
        <tr>
	        <td class="jive-icon"><img src="images/success-16x16.gif" width="16" height="16" border="0" alt=""></td>
	        <td class="jive-icon-label">Settings updated successfully.</td>
        </tr>
    </tbody>
    </table>
    </div><br>

<%  } else if (errors.size() > 0) { %>

    <div class="jive-error">
    <table cellpadding="0" cellspacing="0" border="0">
    <tbody>
        <tr>
        	<td class="jive-icon"><img src="images/error-16x16.gif" width="16" height="16" border="0" alt=""></td>
        	<td class="jive-icon-label">Error saving the settings.</td>
        </tr>
    </tbody>
    </table>
    </div><br>

<%  } %>

<form action="slack-settings.jsp" method="post">

<fieldset>
    <legend>Users</legend>
    <div>
    
    <p>
    The messages from users in this group will be redirected to Slack. 
    </p>

    <table cellpadding="3" cellspacing="0" border="0" width="100%">
    <tbody>
        <tr>
	        <td align="left">User group:&nbsp
                <input type="text" size="20" maxlength="100" name="group" value="<%= (userGroup != null ? userGroup : "") %>">
		        <% if (errors.containsKey("missingUserGroup")) { %>
		            <span class="jive-error-text">
		            <br>Please enter the name of a group.
		            </span>
		        <% } else if (errors.containsKey("userGroupNotFound")) { %>
		            <span class="jive-error-text">
		            <br>Could not find user group. Please try again.
		            </span>
		        <% } %>
	        </td>
	    </tr>
    </tbody>
    </table>
    </div>
</fieldset>

<br><br>

<input type="submit" name="save" value="Save settings">
</form>
	</body>
</html>