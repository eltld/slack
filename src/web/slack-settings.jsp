<%@ page import="java.util.*,
                 berlin.kleinschmit.openfire.plugin.*,
                 org.jivesoftware.openfire.XMPPServer,
                 org.jivesoftware.openfire.group.*,
                 org.jivesoftware.openfire.user.*,
                 org.jivesoftware.util.*,
                 org.xmpp.packet.JID"
%>
<%@ page import="java.util.regex.Pattern"%>

<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jstl/fmt_rt" prefix="fmt" %>

<%
    //get handle to plugin
    SlackRedirectPlugin plugin = (SlackRedirectPlugin) XMPPServer.getInstance().getPluginManager().getPlugin("slack");


    boolean save = request.getParameter("save") != null;
    boolean reload = request.getParameter("reload") != null;
    boolean success = request.getParameter("success") != null;

    String teamName = ParamUtils.getParameter(request, "team");
    String apiToken = ParamUtils.getParameter(request, "token");
    String userGroup = ParamUtils.getParameter(request, "group");
    
    @SuppressWarnings("unchecked")
    Enumeration<String> names = (Enumeration<String>)request.getParameterNames();
    plugin.clearUserSettings();
    while (names.hasMoreElements())
    {
    	String name = names.nextElement();
    	if (name.startsWith("icon-"))
    	{
    		String[] parts = name.split("-");
    		UserSetting userSetting = plugin.getUserSetting(parts[1]);
    		userSetting.setImageUrl(request.getParameter(name));
    	}
    }
    
    Group group = null;
    
    //input validation
    Map<String, String> errors = new HashMap<String, String>();
    if (save) {
    	if (teamName == null || teamName.trim().equals("")) {
    		errors.put("missingTeamName", "missingTeamName");
    	}
    	
    	if (apiToken == null || apiToken.trim().equals("")) {
    		errors.put("missingApiToken", "missingApiToken");
    	}

    	if (userGroup == null || userGroup.trim().equals("")) {
    		errors.put("missingUserGroup", "missingUserGroup");
    	} else {
    		try {
    			group = GroupManager.getInstance().getGroup(userGroup);
    		} catch (GroupNotFoundException gnfe) {
	    		errors.put("userGroupNotFound", "userGroupNotFound");
    		}
    	}

        if (errors.size() == 0) {
        	plugin.setTeamName(teamName);
        	plugin.setApiToken(apiToken);
        	plugin.setGroupName(userGroup);
        	plugin.reloadInterceptors();
        	response.sendRedirect("slack-settings.jsp?success=true");
        }
    } else if (reload) {
    	if (userGroup == null || userGroup.trim().equals("")) {
    		errors.put("missingUserGroup", "missingUserGroup");
    	} else {
    		try {
    			group = GroupManager.getInstance().getGroup(userGroup);
    		} catch (GroupNotFoundException gnfe) {
	    		errors.put("userGroupNotFound", "userGroupNotFound");
    		}
    	}

        if (errors.size() == 0) {
        	plugin.setGroupName(userGroup);
        	plugin.reloadInterceptors();
        }
    } else {
    	teamName = plugin.getTeamName();
    	apiToken = plugin.getApiToken();
    	userGroup = plugin.getGroupName();
    }
    
    if (group == null && userGroup != null && !userGroup.equals(""))
    	try {
    		group = GroupManager.getInstance().getGroup(userGroup);
    	} catch (GroupNotFoundException gnfe) { }
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
    <legend>Slack</legend>
    <div>
    
    <p>
    Please enter the details of your team here. 
    </p>

    <table cellpadding="3" cellspacing="0" border="0" width="100%">
    <tbody>
        <tr>
	        <td align="left">Domain name:&nbsp;
                <input type="text" size="20" maxlength="100" name="team" value="<%= (teamName != null ? teamName: "") %>">.slack.com
		        <% if (errors.containsKey("missingTeamName")) { %>
		            <span class="jive-error-text">
		            <br>Please enter the name of your team.
		            </span>
		        <% } %>
	        </td>
	    </tr>
        <tr>
	        <td align="left"><a href="https://api.slack.com/web" target="_top">API token:</a>&nbsp;
                <input type="text" size="45" maxlength="100" name="token" value="<%= (apiToken != null ? apiToken: "") %>">
		        <% if (errors.containsKey("missingApiToken")) { %>
		            <span class="jive-error-text">
		            <br>Please enter your API token.
		            </span>
		        <% } %>
	        </td>
	    </tr>
    </tbody>
    </table>
    </div>
</fieldset>

<fieldset>
    <legend>Users</legend>
    <div>
    
    <p>
    The messages from users in this group will be redirected to Slack. 
    </p>

    <table cellpadding="3" cellspacing="0" border="0" width="100%">
    <tbody>
        <tr>
	        <td align="left">User group:&nbsp;
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
	        <td>
	        	<input type="submit" name="reload" value="Reload group members">
	        </td>
	    </tr>
    </tbody>
    </table>
    </div>
    
    <%
    	if (group != null) {
    		for (JID jid: group.getMembers())
    		{
    			String userName = jid.getNode();
    			String iconUrl = plugin.getImageUrl(userName);
    %>
    <div class=jive-contentBoxHeader><%= userName %></div>
    <div class=jive-contentBox>
    <table cellpadding="3" cellspacing="0" border="0" width="100%">
    <tbody>
        <tr>
	        <td align="left">Icon URL:&nbsp;
                <input type="text" size="50" maxlength="100" name="icon-<%= userName %>" value="<%= (iconUrl != null ? iconUrl : "") %>">
	        </td>
	    </tr>
    </tbody>
    </table>
    </div>
    <%
    		}
    	}
    %>
</fieldset>

<br><br>

<input type="submit" name="save" value="Save settings">
</form>
	</body>
</html>