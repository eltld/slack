package berlin.kleinschmit.openfire.plugin;

import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.dom4j.Element;
import org.jivesoftware.openfire.interceptor.PacketInterceptor;
import org.jivesoftware.openfire.interceptor.PacketRejectedException;
import org.jivesoftware.openfire.session.Session;
import org.jivesoftware.util.JiveGlobals;
import org.xmpp.packet.Packet;

public class SlackPacketInterceptor implements PacketInterceptor {

	private String userName;
	private String url;
	private String token;
	private String imageUrl;

	public SlackPacketInterceptor(String userName, String url, String token) {
		this.userName = userName;
		this.url = url;
		this.token = token;
		
		imageUrl = JiveGlobals.getProperty(SlackRedirectPlugin.SLACK_IMAGE_URL + userName);
	}

	@Override
	public void interceptPacket(Packet packet, Session session,
			boolean incoming, boolean processed) throws PacketRejectedException {
		if (processed)
			return;

		Element eltMessage = packet.getElement();
		if (eltMessage.getQName().getName().equals("message")) {
			Element eltBody = eltMessage.element("body");
			if (eltBody != null) {

				List<NameValuePair> urlParameters = new ArrayList<NameValuePair>();
				urlParameters.add(new BasicNameValuePair("token", token));
				urlParameters.add(new BasicNameValuePair("channel", "@"
						+ packet.getTo().getNode()));
				urlParameters.add(new BasicNameValuePair("text", eltBody
						.getText()));
				urlParameters.add(new BasicNameValuePair("username", userName));
				
				if (imageUrl != null)
					urlParameters.add(new BasicNameValuePair("icon_url", imageUrl));

				try {
					HttpClient client = new DefaultHttpClient();
					HttpPost post = new HttpPost(url);
					post.setEntity(new UrlEncodedFormEntity(urlParameters));
					client.execute(post);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
	}

	public String getUserName() {
		return userName;
	}

	public String getImageUrl() {
		return imageUrl;
	}

	public void setImageUrl(String imageUrl) {
		this.imageUrl = imageUrl;
	}
}
