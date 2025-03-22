"use client"

import { useState, useEffect, type ChangeEvent } from "react"
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Calendar } from "@/components/ui/calendar"
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"
import { CalendarIcon, Copy, Check } from "lucide-react"
import { format, parse, isValid } from "date-fns"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { toast } from "@/components/ui/use-toast"
import { Toaster } from "@/components/ui/toaster"

export default function Home() {
  const [birthDate, setBirthDate] = useState<Date | undefined>(undefined)
  const [dateInput, setDateInput] = useState<string>("")
  const [inputError, setInputError] = useState<string>("")
  const [age, setAge] = useState<number>(0)
  const [daysUntilBirthday, setDaysUntilBirthday] = useState<number>(0)
  const [monthsUntilBirthday, setMonthsUntilBirthday] = useState<number>(0)
  const [isBirthday, setIsBirthday] = useState<boolean>(false)
  const [isCopied, setIsCopied] = useState<boolean>(false)

  useEffect(() => {
    // Load saved birth date from localStorage
    const savedDate = localStorage.getItem("birthDate")
    if (savedDate) {
      const parsedDate = new Date(savedDate)
      setBirthDate(parsedDate)
      setDateInput(format(parsedDate, "MM/dd/yyyy"))
    }
  }, [])

  useEffect(() => {
    if (birthDate) {
      // Save to localStorage
      localStorage.setItem("birthDate", birthDate.toISOString())

      // Calculate age and days until birthday
      const ageInfo = calculateAgeAndNextBirthday(birthDate)
      setAge(ageInfo.years)
      setDaysUntilBirthday(ageInfo.daysUntilBirthday)
      setMonthsUntilBirthday(ageInfo.monthsUntilBirthday)
      setIsBirthday(ageInfo.daysUntilBirthday === 0)
    }
  }, [birthDate])

  const handleDateInputChange = (e: ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value
    setDateInput(value)

    // Clear previous error
    setInputError("")

    // Only try to parse if we have a complete date format
    if (value.length === 10) {
      try {
        // Parse the date in MM/DD/YYYY format
        const parsedDate = parse(value, "MM/dd/yyyy", new Date())

        // Check if the date is valid and not in the future
        if (isValid(parsedDate)) {
          if (parsedDate > new Date()) {
            setInputError("Date cannot be in the future")
          } else {
            setBirthDate(parsedDate)
          }
        } else {
          setInputError("Invalid date format")
        }
      } catch (error) {
        setInputError("Invalid date format")
      }
    }
  }

  const handleCalendarSelect = (date: Date | undefined) => {
    if (date) {
      setBirthDate(date)
      setDateInput(format(date, "MM/dd/yyyy"))
    }
  }

  const copyAgeToClipboard = async () => {
    try {
      await navigator.clipboard.writeText(age.toString())
      setIsCopied(true)

      // Show toast notification
      toast({
        title: "Copied to clipboard",
        description: `Age ${age} has been copied to your clipboard.`,
      })

      // Reset the copied state after 2 seconds
      setTimeout(() => {
        setIsCopied(false)
      }, 2000)
    } catch (err) {
      toast({
        title: "Failed to copy",
        description: "Could not copy to clipboard. Please try again.",
        variant: "destructive",
      })
    }
  }

  const calculateAgeAndNextBirthday = (birthDate: Date) => {
    const today = new Date()

    // Calculate age in years
    let years = today.getFullYear() - birthDate.getFullYear()

    // Adjust age if birthday hasn't occurred yet this year
    const birthdayThisYear = new Date(today.getFullYear(), birthDate.getMonth(), birthDate.getDate())
    if (today < birthdayThisYear) {
      years--
    }

    // Calculate next birthday
    let nextBirthday = new Date(today.getFullYear(), birthDate.getMonth(), birthDate.getDate())
    if (nextBirthday < today) {
      nextBirthday = new Date(today.getFullYear() + 1, birthDate.getMonth(), birthDate.getDate())
    }

    // Calculate time until next birthday
    const diffTime = nextBirthday.getTime() - today.getTime()
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))

    // Calculate months and remaining days
    let months = 0
    let days = diffDays

    if (diffDays > 30) {
      months = Math.floor(diffDays / 30)
      days = diffDays % 30
    }

    return {
      years,
      daysUntilBirthday: days,
      monthsUntilBirthday: months,
    }
  }

  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-4 bg-gray-100">
      <div className="max-w-md w-full space-y-8">
        <h1 className="text-2xl font-bold text-center">Age Calculator Widget</h1>

        <Card className="p-6 bg-black text-white border-0">
          <div className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="dob" className="text-white">
                Date of Birth (MM/DD/YYYY)
              </Label>
              <Input
                id="dob"
                type="text"
                placeholder="MM/DD/YYYY"
                value={dateInput}
                onChange={handleDateInputChange}
                className="text-center bg-gray-800 text-white border-gray-700"
              />
              {inputError && <p className="text-sm text-red-400">{inputError}</p>}
              <p className="text-xs text-gray-400 text-center">Enter date in MM/DD/YYYY format</p>
            </div>

            <div className="flex justify-center">
              <Popover>
                <PopoverTrigger asChild>
                  <Button variant="outline" className="w-full bg-gray-800 text-white border-gray-700 hover:bg-gray-700">
                    <CalendarIcon className="mr-2 h-4 w-4" />
                    {birthDate ? format(birthDate, "PPP") : <span>Or select from calendar</span>}
                  </Button>
                </PopoverTrigger>
                <PopoverContent className="w-auto p-0">
                  <Calendar
                    mode="single"
                    selected={birthDate}
                    onSelect={handleCalendarSelect}
                    initialFocus
                    disabled={(date) => date > new Date()}
                    className="bg-gray-800 text-white"
                  />
                </PopoverContent>
              </Popover>
            </div>
          </div>
        </Card>

        {birthDate && (
          <div className="space-y-4">
            <Card className="p-6 bg-black text-white shadow-md rounded-xl border-0">
              <div className="space-y-2 text-center relative">
                <h2 className="text-sm font-medium text-gray-300">Current Age</h2>
                <div className="flex items-center justify-center">
                  <p className="text-5xl font-bold text-white">{age}</p>
                  <Button
                    variant="ghost"
                    size="sm"
                    className="ml-2 text-gray-300 hover:text-white hover:bg-gray-800"
                    onClick={copyAgeToClipboard}
                    aria-label="Copy age to clipboard"
                  >
                    {isCopied ? <Check className="h-4 w-4" /> : <Copy className="h-4 w-4" />}
                  </Button>
                </div>
                <p className="text-sm text-gray-300">years old</p>
              </div>
            </Card>

            <Card className="p-6 bg-black text-white shadow-md rounded-xl border-0">
              <div className="space-y-2 text-center">
                <h2 className="text-sm font-medium text-gray-300">Next Birthday</h2>
                {isBirthday ? (
                  <p className="text-2xl font-bold text-green-400">Today! 🎉</p>
                ) : (
                  <div>
                    <div className="flex justify-center gap-4">
                      {monthsUntilBirthday > 0 && (
                        <div className="text-center">
                          <p className="text-3xl font-bold text-white">{monthsUntilBirthday}</p>
                          <p className="text-xs text-gray-300">months</p>
                        </div>
                      )}
                      <div className="text-center">
                        <p className="text-3xl font-bold text-white">{daysUntilBirthday}</p>
                        <p className="text-xs text-gray-300">days</p>
                      </div>
                    </div>
                  </div>
                )}
              </div>
            </Card>
          </div>
        )}

        <div className="text-center text-xs text-gray-500">
          <p>Your birth date is saved in your browser</p>
        </div>

        <div className="flex justify-center">
          <Button asChild variant="outline" className="bg-black text-white border-gray-700 hover:bg-gray-800">
            <a href="/widgets">View Widget Styles</a>
          </Button>
        </div>
      </div>
      <Toaster />
    </main>
  )
}

