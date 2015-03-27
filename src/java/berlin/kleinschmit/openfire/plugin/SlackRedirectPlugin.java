package berlin.kleinschmit.openfire.plugin;

import java.io.File;
import java.util.*;

import org.jivesoftware.openfire.container.Plugin;
import org.jivesoftware.openfire.container.PluginManager;
import org.jivesoftware.openfire.group.Group;
import org.jivesoftware.openfire.group.GroupManager;
import org.jivesoftware.openfire.group.GroupNotFoundException;
import org.jivesoftware.openfire.interceptor.InterceptorManager;
import org.jivesoftware.util.JiveGlobals;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xmpp.packet.JID;

public class SlackRedirectPlugin implements Plugin {
	
	public static final String SLACK_GROUP = "slack.group";
	public static final String SLACK_TEAM_NAME = "slack.team";
	public static final String SLACK_API_TOKEN = "slack.apitoken";
	public static final String SLACK_IMAGE_URL = "slack.imageUrl.";

	private static final Logger Log = LoggerFactory.getLogger(SlackRedirectPlugin.class);

	private String groupName;
	private String teamName;
	private String apiToken;
	private Map<String, SlackPacketInterceptor> packetInterceptors;
	private Map<String, UserSetting> userSettings;
	
	public SlackRedirectPlugin()
	{
		packetInterceptors = new HashMap<String, SlackPacketInterceptor>();
		userSettings = new HashMap<String, UserSetting>();
	}

	@Override
	public void initializePlugin(PluginManager manager, File pluginDirectory) {
		groupName = JiveGlobals.getProperty(SLACK_GROUP, "slack");
		teamName = JiveGlobals.getProperty(SLACK_TEAM_NAME, null);
		apiToken = JiveGlobals.getProperty(SLACK_API_TOKEN, null);
		
		reloadInterceptors();
	}

	@Override
	public void destroyPlugin() {
		clearInterceptors();
	}

	private void clearInterceptors() {
		InterceptorManager IM = InterceptorManager.getInstance();
		
		for (SlackPacketInterceptor pi : packetInterceptors.values()) {
			IM.removeUserInterceptor(pi.getUserName(), pi);
		}
		packetInterceptors.clear();
	}

	public void reloadInterceptors() {
		clearInterceptors();
		
		Group group;
		try {
			group = GroupManager.getInstance().getGroup(getGroupName());
		} catch (GroupNotFoundException e) {
			Log.error("Group '%1s' does not exist");
			return;
		}
	
		InterceptorManager IM = InterceptorManager.getInstance();
	
		for (JID jid : group.getMembers()) {
	
			String name = jid.getNode();
			SlackPacketInterceptor pi = new SlackPacketInterceptor(name, teamName, apiToken);
			
			if (userSettings.containsKey(name))
				pi.setImageUrl(userSettings.get(name).getImageUrl());
			
			IM.addUserInterceptor(name, 0, pi);
			packetInterceptors.put(name, pi);
		}
	}
	
	public void reset()
	{
		setGroupName(null);
	}

	public String getGroupName() {
		return groupName;
	}

	public void setGroupName(String groupName) {
		this.groupName = groupName;
		JiveGlobals.setProperty(SLACK_GROUP, groupName);
	}
	
	public String getTeamName() {
		return teamName;
	}
	
	public void setTeamName(String teamName)
	{
		this.teamName = teamName;
		JiveGlobals.setProperty(SLACK_TEAM_NAME, teamName);
	}
	
	public String getApiToken() {
		return apiToken;
	}
	
	public void setApiToken(String apiToken)
	{
		this.apiToken = apiToken;
		JiveGlobals.setProperty(SLACK_API_TOKEN, apiToken);
	}
	
	public String getImageUrl(String userName) {
		SlackPacketInterceptor pi = packetInterceptors.get(userName);
		if (pi != null)
			return pi.getImageUrl();
		else
			return null;
	}
	
	public void setImageUrl(String userName, String imageUrl) {
		SlackPacketInterceptor pi = packetInterceptors.get(userName);
		if (pi != null)
			pi.setImageUrl(imageUrl);
	}
	
	public void clearUserSettings() {
		userSettings.clear();
	}
	
	public UserSetting getUserSetting(String userName) {
		if (userSettings.containsKey(userName))
			return userSettings.get(userName);
		else {
			UserSetting userSetting = new UserSetting(userName);
			userSettings.put(userName, userSetting);
			return userSetting;
		}
	}
}
