import { UnavailabilityError } from "expo-modules-core";
import ExpoHaptics from "./ExpoHaptics";
import { NotificationFeedbackType, ImpactFeedbackStyle } from "./Haptics.types";

export async function notificationAsync(
  type = NotificationFeedbackType.Success
) {
  if (!ExpoHaptics.notificationAsync) {
    throw new UnavailabilityError("Haptics", "notificationAsync");
  }
  await ExpoHaptics.notificationAsync(type);
}

export async function impactAsync(style = ImpactFeedbackStyle.Medium) {
  if (!ExpoHaptics.impactAsync) {
    throw new UnavailabilityError("Haptic", "impactAsync");
  }
  await ExpoHaptics.impactAsync(style);
}

export async function selectionAsync() {
  if (!ExpoHaptics.selectionAsync) {
    throw new UnavailabilityError("Haptic", "selectionAsync");
  }
  await ExpoHaptics.selectionAsync();
}

export async function playHapticSequenceAsync(sequence) {
  if (!ExpoHaptics.playHapticSequenceAsync) {
    throw new UnavailabilityError("Haptic", "playHapticSequenceAsync");
  }
  await ExpoHaptics.playHapticSequenceAsync(sequence);
}

export async function stopHapticSequence() {
  if (!ExpoHaptics.stopHapticSequence) {
    throw new UnavailabilityError("Haptic", "stopHapticSequence");
  }
  await ExpoHaptics.stopHapticSequence();
}

export { NotificationFeedbackType, ImpactFeedbackStyle };
