importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyDnqmUI5Uxo_VdlbGOAK1EAlgOnC2ZeJBg",
  authDomain: "wfm-navy.firebaseapp.com",
  projectId: "wfm-navy",
  storageBucket: "wfm-navy.appspot.com",
  messagingSenderId: "481843582569",
  appId: "1:481843582569:web:4a7456c577f5520e9cb4f8",
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});