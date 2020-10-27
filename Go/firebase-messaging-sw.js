importScripts('https://www.gstatic.com/firebasejs/5.10.1/firebase-app.js');
importScripts(
  'https://www.gstatic.com/firebasejs/5.10.1/firebase-messaging.js'
);

self.addEventListener('fetch', function(event) {});

firebase.initializeApp({
  messagingSenderId: '1018645828041'
});

const messaging = firebase.messaging();

messaging.setBackgroundMessageHandler(function(payload) {
  console.log(
    '[firebase-messaging-sw.js] Received background message ',
    payload
  );
  // Customize notification here
  var notificationTitle = payload.notification.title; // タイトル
  var notificationOptions = {
    body: payload.notification.body, // 本文
    icon: payload.notification.icon // アイコン
  };

  return self.registration.showNotification(
    notificationTitle,
    notificationOptions
  );
});
