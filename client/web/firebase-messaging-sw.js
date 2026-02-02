importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: "AIzaSyAq8FIYAloIj7DcLIuzlXC0JY3GWi-ffCM",
    authDomain: "kejapin-46148.firebaseapp.com",
    projectId: "kejapin-46148",
    storageBucket: "kejapin-46148.firebasestorage.app",
    messagingSenderId: "698029781603",
    appId: "1:698029781603:web:c7c4a36adc6ba265a63e56",
    measurementId: "G-XNW5L0DVR4"
});

const messaging = firebase.messaging();

// Optional: Handle background messages
messaging.onBackgroundMessage((payload) => {
    console.log('[firebase-messaging-sw.js] Received background message ', payload);
    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
        icon: '/icons/Icon-192.png'
    };

    return self.registration.showNotification(notificationTitle, notificationOptions);
});
