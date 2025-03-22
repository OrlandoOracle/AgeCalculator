import { parse, isValid, format } from "date-fns"

export function parseDateString(dateString: string): Date | null {
  try {
    // Try to parse the date in MM/DD/YYYY format
    const parsedDate = parse(dateString, "MM/dd/yyyy", new Date())

    // Check if the date is valid
    if (isValid(parsedDate)) {
      return parsedDate
    }
    return null
  } catch (error) {
    return null
  }
}

export function formatDateString(date: Date): string {
  return format(date, "MM/dd/yyyy")
}

export function isDateInFuture(date: Date): boolean {
  return date > new Date()
}

