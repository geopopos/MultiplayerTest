extends Node


var X509_cert_filename = "X509_Certificate.crt"
var X509_key_filename = "x509_Key.key"
onready var x509_cert_path = "user://Certificate/" + X509_cert_filename
onready var x509_key_path = "user://Certificate/" + X509_key_filename

var CN = "MultiplayerTutorial"
var O = "Geopopos"
var C = "US"
var not_before = "20221130000000"
var not_after = "20231129235900"

func _ready():
	var directory = Directory.new()
	if directory.dir_exists("user://Certificate"):
		pass
	else:
		directory.make_dir("user://Certificate")
	CreateX509Cert()
	print("Certificate Created")

func CreateX509Cert():
	var CNOC = "CN=" + CN + ",O=" + O + ",C=" + C
	var crypto = Crypto.new()
	var crypto_key = crypto.generate_rsa(4096)
	var X509_cert = crypto.generate_self_signed_certificate(crypto_key, CNOC, not_before, not_after)
	X509_cert.save(x509_cert_path)
	crypto_key.save(x509_key_path)
