/**
 * Takes a time of day string like "TimeOfDay(14:30)" and converts it to a more
 * human-readable format like "2:30 PM".
 */
export const timeOfDayStringToTime = (timeOfDay: string) => {
  const timeMatch = timeOfDay.match(/TimeOfDay\((\d{1,2}):(\d{2})\)/);
  if (!timeMatch) {
    return "";
  }
  let hours = parseInt(timeMatch[1], 10);
  const minutes = parseInt(timeMatch[2], 10);
  const period = hours >= 12 ? "PM" : "AM";
  hours = hours % 12;
  if (hours === 0) {
    hours = 12;
  }
  const minutesStr =
    minutes > 0 ? `:${minutes.toString().padStart(2, "0")}` : "";
  return `${hours}${minutesStr} ${period}`;
};
