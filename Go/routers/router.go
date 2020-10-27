package routers

import (
	"app/controllers"

	"github.com/astaxie/beego"
)

func init() {
	beego.Router("/", &controllers.MainController{})
	// beego.Router("/:search-word", &controllers.MainController{}, "*:Post")
}
