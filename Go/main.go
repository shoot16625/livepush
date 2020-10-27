package main

import (
	_ "app/routers"
	"fmt"
	"os"
	"strconv"

	"github.com/astaxie/beego"
)

func main() {
	// heroku
	port, _ := strconv.Atoi(os.Getenv("PORT"))
	fmt.Println(port)
	if port == 0 {
		port = 8080
	}
	beego.BConfig.Listen.HTTPPort = port
	beego.BConfig.Listen.HTTPSPort = port

	beego.BConfig.WebConfig.StaticDir["/manifest.json"] = "manifest.json"
	beego.BConfig.WebConfig.StaticDir["/firebase-messaging-sw.js"] = "firebase-messaging-sw.js"
	beego.BConfig.WebConfig.StaticDir["/serviceAccountKey.json"] = "serviceAccountKey.json"
	beego.Run()
}
