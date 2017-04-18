
import { NativeModules, DeviceEventEmitter } from 'react-native'

const { RNPushyNotifications } = NativeModules

//Configure the notifications that will be created.
//Send an object (optional) to override the values in the defaultConfiguration.
async function configure() {
  return await RNPushyNotifications.configure()
}

//Pass your topic: "my-topic". Should match: [a-zA-Z0-9-_.]+
async function subscribe(topic) {
  return await RNPushyNotifications.subscribe(topic)
}

//Pass your topic: "my-topic". Should match: [a-zA-Z0-9-_.]+
async function unsubscribe(topic) {
  return await RNPushyNotifications.unsubscribe(topic)
}

//Pass your topic: "my-topic". Should match: [a-zA-Z0-9-_.]+
async function toggleNotifications(enabled) {
  return await RNPushyNotifications.toggleNotifications(enabled)
}

//This listener will catch incoming notification events.
const setNotificationReceivedListener = (onNotificationReceived) => {
  return DeviceEventEmitter.addListener('NotificationReceived', onNotificationReceived)
}

const PushyNotifications = {
  configure,
  subscribe,
  unsubscribe,
  toggleNotifications,
  setNotificationReceivedListener
}

export default PushyNotifications
