package controllers

import (
	"encoding/json"
	"fmt"
	"log"
	"net/url"
	"strconv"
	"strings"
	"time"

	"golang.org/x/net/context"
	"google.golang.org/api/option"

	firebase "firebase.google.com/go"
	"firebase.google.com/go/messaging"
	"github.com/ChimeraCoder/anaconda"
	"github.com/astaxie/beego"
)

type MainController struct {
	beego.Controller
}

func (c *MainController) Get() {
	c.TplName = "index.tpl"
}

type SearchWord struct {
	Word   string
	Tweets []anaconda.Tweet
	Push   bool
	Token  string
}

func (c *MainController) Post() {
	var resp SearchWord
	json.Unmarshal(c.Ctx.Input.RequestBody, &resp)
	if resp.Word == "" {
		c.Ctx.Output.SetStatus(403)
	} else {
		searchResult := GetTwitter(resp.Word)
		normalizeResult := NormalizeTwitter(searchResult)
		resp.Tweets = normalizeResult
		normalizeResult = judgeTwitter(normalizeResult)
		resp.Push = JudgePush(normalizeResult)
		if resp.Push {
			SendToToken(resp.Token, resp.Word)
		}
		c.Ctx.Output.SetStatus(200)
	}
	c.Data["json"] = resp
	c.ServeJSON()
}

// twitter-apiに接続
func GetTwitterApi() *anaconda.TwitterApi {
	api := anaconda.NewTwitterApiWithCredentials(beego.AppConfig.String("your-access-token"), beego.AppConfig.String("your-access-token-secret"), beego.AppConfig.String("your-consumer-key"), beego.AppConfig.String("your-consumer-secret"))
	return api
}

// ツイートを取得する
func GetTwitter(keyword string) anaconda.SearchResponse {
	api := GetTwitterApi()
	v := url.Values{}
	v.Set("count", "1000")
	searchResult, _ := api.GetSearch(keyword, v)
	return searchResult
}

// 取得したツイートを厳選する（表示用）
func NormalizeTwitter(searchResult anaconda.SearchResponse) (res []anaconda.Tweet) {
	for _, tweet := range searchResult.Statuses {
		if tweet.RetweetedStatus == nil {
			t, _ := time.Parse("Mon Jan 2 15:04:05 -0700 2006", tweet.CreatedAt)
			sec := time.Since(t).String()
			sec = strings.Split(sec, ".")[0]
			tweet.CreatedAt = sec + "s ago"
			res = append(res, tweet)
		}
	}
	return res
}

// 判定用ツイートに精錬化
func judgeTwitter(searchResult []anaconda.Tweet) (res []anaconda.Tweet) {
	delayTime := 30
	for _, tweet := range searchResult {
		sec := strings.Split(tweet.CreatedAt, "s")[0]
		if !strings.Contains(sec, "m") {
			secInt, _ := strconv.Atoi(sec)
			if secInt < delayTime {
				res = append(res, tweet)
			}
		}
	}
	return res
}

// プッシュ通知を送信するか判定
func JudgePush(searchResult []anaconda.Tweet) bool {
	n := 0
	threshold := 2
	Judgewords := [...]string{"始まり", "はじまり", "始まっ", "はじまっ", "始まる", "はじまる", "きそう", "来そう", "きた", "来た", "キタ", "もうすぐ"}
	for _, tweet := range searchResult {
		for _, word := range Judgewords {
			if strings.Contains(tweet.FullText, word) {
				n++
				break
			}
		}
	}
	fmt.Println("hit count:", n)
	var push bool = false
	if n >= threshold {
		push = true
	}
	return push
}

// push通知を送信する
func SendToToken(RegistrationToken string, SearchWord string) {
	ctx := context.Background()
	opt := option.WithCredentialsFile("/serviceAccountKey.json")

	app, err := firebase.NewApp(ctx, nil, opt)
	if err != nil {
		log.Fatalln(err)
		return
	}

	client, err := app.Messaging(ctx)
	if err != nil {
		log.Fatalln(err)
		return
	}

	message := &messaging.Message{
		Notification: &messaging.Notification{
			Title: SearchWord + " will start !!",
			Body:  "そろそろ始まりそうですよ。",
		},
		Token: RegistrationToken,
	}

	response, err := client.Send(ctx, message)
	if err != nil {
		log.Fatalln(err)
	}
	fmt.Println("Successfully sent message:", response)
}
