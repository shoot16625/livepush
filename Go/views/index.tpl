<!DOCTYPE html>
<html lang="ja">
  <head>
    <title>livepush</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta http-equiv="Content-Style-Type" content="text/css" />
    <meta http-equiv="Content-Script-Type" content="text/javascript" />
    <meta http-equiv="content-language" content="ja" />
    <meta name="application-name" content="livepush" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1, shrink-to-fit=no"
    />
    <meta
      name="description"
      content="テレビの見逃しを防いでくれるプッシュ通知サービス"
    />
    <meta name="keywords" content="ライブプッシュ,見逃し,アラーム,通知" />
    <meta property="og:title" content="livepush" />
    <meta property="og:type" content="website" />
    <meta
      property="og:description"
      content="テレビの見逃しを防いでくれるプッシュ通知サービス"
    />
    <link rel="icon" href="/static/img/bell-48x48.ico" />
    <!-- スマホ用アイコン -->
    <link
      rel="apple-touch-icon"
      sizes="128x128"
      href="/static/img/bell-128x128.png"
    />
    <link
      rel="icon"
      type="image/png"
      href="/static/img/bell-192x192.png"
      sizes="192x192"
    />
    <!-- ホーム画面に表示されるアプリ名 -->
    <meta name="apple-mobile-web-app-title" content="livepush" />

    <!-- ツイッターカード -->
    <meta name="twitter:card" content="summary" />
    <meta name="twitter:site" content="@playtag551" />
    <meta property="og:url" content="https://livepush.shijimi.work" />
    <meta property="og:title" content="livepush" />
    <meta
      property="og:description"
      content="テレビの見逃しを防いでくれるプッシュ通知サービス"
    />
    <meta
      property="og:image"
      content="https://livepush.shijimi.work/static/img/bell-128x128.png"
    />
    <link
      rel="stylesheet"
      href="https://cdnjs.cloudflare.com/ajax/libs/onsen/2.10.10/css/onsenui.min.css"
    />
    <link
      rel="stylesheet"
      href="https://cdnjs.cloudflare.com/ajax/libs/onsen/2.10.10/css/onsen-css-components.min.css"
    />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/onsen/2.10.10/js/onsenui.min.js"></script>

    <link rel="stylesheet" type="text/css" href="/static/css/common.css" />

    <link rel="manifest" href="/manifest.json" />

    <script src="https://www.gstatic.com/firebasejs/5.10.1/firebase-app.js"></script>
    <script src="https://www.gstatic.com/firebasejs/5.10.1/firebase-messaging.js"></script>
  </head>
  <body>
    <ons-page>
      <div class="background" style="background-color: white;"></div>
      <ons-card style="text-align: center; background: aliceblue;">
        <h1>LivePush <img src="/static/img/bell-16x16.png" /></h1>
        <ons-list-item expandable>
          紹介
          <div class="expandable-content">
            <div class="area-left">
              Mステやサッカーの試合を視聴していると、
              「あのアーティストが出てきたら見よう」とか
              「後半戦はじまるまで別番組」なんてことありませんか？<br />
              結局見逃してしまったり...<br />
              本サービスは、特定のキーワードに反応して、
              あなたのデバイスにプッシュ通知を送信し、見逃しを防止するサービスです。
            </div>
          </div>
        </ons-list-item>
        <ons-list-item expandable>
          使い方
          <div class="expandable-content">
            <ol class="area-left">
              <li>プッシュ通知を有効化します。</li>
              <li>
                キーワード（ex.サッカー、欅坂46）を入力して、Enterを押し登録します。
              </li>
              <li>
                15秒ごとにキーワードに関するTwitterを検索し、「もうすぐ」や「始まりそう」などの単語に反応して、プッシュ通知と音でお知らせします。
              </li>
              <li>設定を解除する場合は、ブラウザをリロードしてください。</li>
            </ol>
          </div>
        </ons-list-item>
      </ons-card>
      <ons-row style="margin-top: 20px;">
        <ons-col width="15%"></ons-col>
        <ons-col>
          <ons-search-input
            id="search-word"
            placeholder="キーワード"
            style="width: 100%; margin-bottom: 20px;"
          >
          </ons-search-input>
        </ons-col>
        <ons-col width="15%"></ons-col>
      </ons-row>
      <div class="area-center">
        <ons-button
          id="subscribe-button"
          class="area-center"
          style="background: cadetblue;"
          onclick="getSubscription()"
        ></ons-button>
      </div>
      <ons-button
        modifier="quiet"
        class="add-button area-right"
        style="font-size: 14px;"
        >ホーム画面にブックマークする</ons-button
      >
      <div class="area-right">
        <a
          href="https://twitter.com/share"
          class="twitter-share-button"
          data-url="https://livepush.shijimi.work/"
          data-text="見逃し防止プッシュ通知サービス"
          data-hashtags="livepush"
          >Tweet</a
        >
        ※iosには対応しておりません。
      </div>
      <ons-list>
        <ons-lazy-repeat id="timeline"></ons-lazy-repeat>
      </ons-list>
      <audio id="sound-file" preload="auto">
        <source src="/static/img/push_sound.mp3" type="audio/mp3" />
        <source src="/static/img/push_sound.wav" type="audio/wav" />
      </audio>
    </ons-page>

    <script>
      URL = 'https://livepush.shijimi.work/';
      // URL = 'http://localhost:36000/';
      MYTOKEN = '';

      // Firebase のSDKを利用し、SenderIDを設定して初期化
      const config = {
        apiKey: 'AIzaSyDnoDBu2j0QDasPXMJau8lAm2AOsKSDuxI',
        authDomain: 'livepush-shijimi.firebaseapp.com',
        databaseURL: 'https://livepush-shijimi.firebaseio.com',
        projectId: 'livepush-shijimi',
        storageBucket: 'livepush-shijimi.appspot.com',
        messagingSenderId: '1018645828041',
        appId: '1:1018645828041:web:91fbb333d4883da6569818',
        measurementId: 'G-4K77XMXGLR',
      };
      firebase.initializeApp(config);

      const messaging = firebase.messaging();
      messaging.usePublicVapidKey(
        'BNuMap2WAkGcmUCrKBauYFoxQ3-2XeaoSZ_F7aTQfrUOapN9laiktMCTV5463hUd9XZFO_V5r1RJmNzkXjeMEUU'
      );

      // Service Worker ファイルを登録し、ボタン表示を行う
      registSW();
      getToken();
      initialButton();

      messaging.onMessage((payload) => {
        // console.log('Message received. ', payload);
        var notificationTitle = payload.notification.title; // タイトル
        var notificationOptions = {
          body: payload.notification.body, // 本文
          icon: payload.notification.icon, // アイコン
        };

        showNotification(notificationTitle, notificationOptions);
      });

      let target = document.getElementById('search-word');
      target.addEventListener('change', sendWord);
      setInterval(sendWord, 15000);

      function showNotification(title, options) {
        Notification.requestPermission(function (result) {
          if (result === 'granted') {
            navigator.serviceWorker.ready.then(function (registration) {
              registration.showNotification(title, options);
            });
          }
        });
      }

      function initialButton() {
        messaging
          .getToken()
          .then((token) => {
            if (token) {
              document.getElementById('subscribe-button').innerText =
                'プッシュ通知を購読中';
            } else {
              document.getElementById('subscribe-button').innerText =
                'プッシュ通知を有効化する';
            }
          })
          .catch(function (err) {
            console.log('An error occurred while retrieving token. ', err);
          });
      }

      // トークンが未取得の場合 = プッシュ通知を未購読の場合、プッシュ通知の登録許可を行う
      // すでに購読済みの場合、取得済みのFirebase用トークンを表示
      function getSubscription() {
        messaging
          .getToken()
          .then((token) => {
            if (!token) {
              getNotification();
            } else {
              getToken();
            }
          })
          .catch(function (err) {
            console.log('An error occurred while retrieving token. ', err);
          });
      }

      //  Firebase のSDKを使い、プッシュ通知の購読処理を行う
      function getNotification() {
        messaging
          .requestPermission()
          .then(function () {
            console.log('Notification permission granted.');
            getToken();
            initialButton();
          })
          .catch(function (err) {
            console.log('Unable to get permission to notify.', err);
          });
      }

      //　トークン表示
      function getToken() {
        messaging
          .getToken()
          .then((token) => {
            if (token) {
              MYTOKEN = token;
              // console.log(token);
            } else {
              console.log(
                'No Instance ID token available. Request permission to generate one.'
              );
            }
          })
          .catch(function (err) {
            console.log('An error occurred while retrieving token. ', err);
          });
      }

      //　Service Worker ファイルを登録
      function registSW() {
        if ('serviceWorker' in navigator) {
          window.addEventListener('load', function () {
            navigator.serviceWorker.register('/firebase-messaging-sw.js').then(
              function (registration) {
                console.log(
                  'firebase-messaging-sw.js registration successful with scope: ',
                  registration.scope
                );
              },
              function (err) {
                console.log(
                  'firebase-messaging-sw.js registration failed: ',
                  err
                );
              }
            );
          });
        }
      }

      // キーワードの送信・データ取得
      function sendWord() {
        getToken();
        if (MYTOKEN === '') {
          return;
        }
        let target = document.getElementById('search-word');
        if (target.value == '') {
          return;
        }
        let data = {};
        data.Word = target.value.replace('　', ' ').trim();
        data.Token = MYTOKEN;
        let url = URL;
        var json = JSON.stringify(data);
        var request = new XMLHttpRequest();
        request.open('POST', url, true);
        request.setRequestHeader(
          'Content-type',
          'application/json; charset=utf-8'
        );
        request.send(json);
        request.onload = function () {
          if (request.readyState == 4 && request.status == '200') {
            var x = JSON.parse(request.responseText);
            // console.log(x);
            if (x.Push) {
              sound();
            }
            showTimeline(x.Tweets);
          } else {
          }
        };
      }

      // タイムラインの表示
      function showTimeline(timeline) {
        ons.ready(function () {
          const comments = timeline;
          var infiniteList = document.getElementById('timeline');
          if (timeline != null) {
            infiniteList.delegate = {
              createItemContent: function (i) {
                return ons.createElement(
                  '<div id="tweetID-' +
                    comments[i].id +
                    '"><ons-list-header style="background-color:aliceblue;text-transform:none;"><div class="area-left comment-list-header-font">@' +
                    comments[i].user.name +
                    '</div><div class="area-right list-margin">' +
                    comments[i].created_at +
                    '</div></ons-list-header><ons-list-item><div class="left"><img class="list-item__thumbnail" src="' +
                    comments[i].user.profile_image_url_https +
                    '"></div><div class="center"><span class="list-item__subtitle comment-list-content-font" id="tweet-' +
                    String(i) +
                    '">' +
                    comments[i].full_text +
                    '</span><span class="list-item__subtitle area-right"></span></div></ons-list-item></div>'
                );
              },
              countItems: function () {
                return comments.length;
              },
            };
            infiniteList.refresh();
          }
        });
      }

      // インストールボタンの機能
      let deferredPrompt;
      const addBtn = document.querySelector('.add-button');
      addBtn.style.display = 'none';
      window.addEventListener('beforeinstallprompt', (e) => {
        e.preventDefault();
        deferredPrompt = e;
        addBtn.style.display = 'block';

        addBtn.addEventListener('click', (e) => {
          addBtn.style.display = 'none';
          deferredPrompt.prompt();
          deferredPrompt.userChoice.then((choiceResult) => {
            if (choiceResult.outcome === 'accepted') {
              console.log('User accepted the A2HS prompt');
            } else {
              console.log('User dismissed the A2HS prompt');
            }
            deferredPrompt = null;
          });
        });
      });

      function sound() {
        var id = 'sound-file';
        // 初回以外だったら音声ファイルを巻き戻す
        if (typeof document.getElementById(id).currentTime != 'undefined') {
          document.getElementById(id).currentTime = 0;
        }
        document.getElementById(id).play();
      }

      // ツイッターガジェット
      !(function (d, s, id) {
        var js,
          fjs = d.getElementsByTagName(s)[0],
          p = /^http:/.test(d.location) ? 'http' : 'https';
        if (!d.getElementById(id)) {
          js = d.createElement(s);
          js.id = id;
          js.src = p + '://platform.twitter.com/widgets.js';
          fjs.parentNode.insertBefore(js, fjs);
        }
      })(document, 'script', 'twitter-wjs');
    </script>
  </body>
</html>
