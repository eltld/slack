package berlin.kleinschmit.openfire.plugin;

public class UserSetting {
	private String userName;
	private String imageUrl;
	
	public UserSetting(String userName) {
		this.userName = userName;
	}
	
	public String getUserName() {
		return userName;
	}
	
	public String getImageUrl() {
		return imageUrl;
	}
	
	public void  setImageUrl(String imageUrl) {
		this.imageUrl = imageUrl;
	}
};