extends Node

var admob = null
var real_ads = false
var banner_top = false
# Fill these from your AdMob account:

var ad_banner_id = "ca-app-pub-9471984531831819/8519289122"
var ad_interstitial_id = ""
var enable_ads = true


func _ready():
	if Engine.has_singleton("AdMob"):
		Logger.info("Found AdMob", "AdMob")
		admob = Engine.get_singleton("AdMob")
		admob.init(real_ads, get_instance_id())
		admob.loadBanner(ad_banner_id, banner_top)
		admob.loadInterstitial(ad_interstitial_id)
	else:
		Logger.error("Did not find AdMob", "AdMob")


func show_ad_banner():
	if admob and enable_ads:
		return OK
		admob.showBanner()
	return FAILED


func hide_ad_banner():
	if admob:
		admob.hideBanner()


func show_ad_interstitial():
	if admob and enable_ads:
		admob.showInterstitial()


func _on_interstitial_close():
	if admob and enable_ads:
		show_ad_banner()
