"use client"

import { useState, useEffect } from "react"
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Copy, Check } from "lucide-react"
import { format } from "date-fns"
import { toast } from "@/components/ui/use-toast"
import { Toaster } from "@/components/ui/toaster"

interface AgeWidgetProps {
  className?: string
  compact?: boolean
  showDate?: boolean
}

export function AgeWidget({ className = "", compact = false, showDate = false }: AgeWidgetProps) {
  const [birthDate, setBirthDate] = useState<Date | undefined>(undefined)
  const [age, setAge] = useState<number>(0)
  const [daysUntilBirthday, setDaysUntilBirthday] = useState<number>(0)
  const [monthsUntilBirthday, setMonthsUntilBirthday] = useState<number>(0)
  const [isBirthday, setIsBirthday] = useState<boolean>(false)
  const [isCopied, setIsCopied] = useState<boolean>(false)

  useEffect(() => {
    // Load saved birth date from localStorage
    const savedDate = localStorage.getItem("birthDate")
    if (savedDate) {
      setBirthDate(new Date(savedDate))
    }
  }, [])

  useEffect(() => {
    if (birthDate) {
      // Calculate age and days until birthday
      const ageInfo = calculateAgeAndNextBirthday(birthDate)
      setAge(ageInfo.years)
      setDaysUntilBirthday(ageInfo.daysUntilBirthday)
      setMonthsUntilBirthday(ageInfo.monthsUntilBirthday)
      setIsBirthday(ageInfo.daysUntilBirthday === 0)
    }
  }, [birthDate])

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

  if (!birthDate) {
    return (
      <Card className={`p-4 text-center bg-black text-white ${className}`}>
        <p className="text-sm text-gray-300">Please set your birth date first</p>
      </Card>
    )
  }

  if (compact) {
    return (
      <Card className={`p-4 bg-black text-white ${className}`}>
        <div className="flex justify-between items-center">
          <div className="flex items-center">
            <p className="text-xs text-gray-300">Age</p>
            <Button
              variant="ghost"
              size="sm"
              className="ml-1 p-0 h-6 text-gray-300 hover:text-white hover:bg-gray-800"
              onClick={copyAgeToClipboard}
              aria-label="Copy age to clipboard"
            >
              {isCopied ? <Check className="h-3 w-3" /> : <Copy className="h-3 w-3" />}
            </Button>
          </div>
          <p className="text-2xl font-bold text-white">{age}</p>
          <div>
            <p className="text-xs text-gray-300">Next Birthday</p>
            {isBirthday ? (
              <p className="text-sm font-bold text-green-400">Today! 🎉</p>
            ) : (
              <p className="text-sm font-medium text-white">
                {monthsUntilBirthday > 0 ? `${monthsUntilBirthday}m ` : ""}
                {daysUntilBirthday}d
              </p>
            )}
          </div>
        </div>
        {showDate && (
          <div className="mt-2 text-xs text-gray-300 text-center">DOB: {format(birthDate, "MM/dd/yyyy")}</div>
        )}
      </Card>
    )
  }

  return (
    <Card className={`p-6 bg-black text-white ${className}`}>
      <div className="space-y-4">
        <div className="text-center">
          <h2 className="text-sm font-medium text-gray-300">Current Age</h2>
          <div className="flex items-center justify-center mt-1">
            <p className="text-4xl font-bold text-white">{age}</p>
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
          <p className="text-xs text-gray-300">years old</p>
          {showDate && <p className="text-xs text-gray-300 mt-1">Born: {format(birthDate, "MM/dd/yyyy")}</p>}
        </div>

        <div className="h-px bg-gray-700" />

        <div className="text-center">
          <h2 className="text-sm font-medium text-gray-300">Next Birthday</h2>
          {isBirthday ? (
            <p className="text-xl font-bold text-green-400">Today! 🎉</p>
          ) : (
            <div className="flex justify-center gap-4 mt-1">
              {monthsUntilBirthday > 0 && (
                <div className="text-center">
                  <p className="text-2xl font-bold text-white">{monthsUntilBirthday}</p>
                  <p className="text-xs text-gray-300">months</p>
                </div>
              )}
              <div className="text-center">
                <p className="text-2xl font-bold text-white">{daysUntilBirthday}</p>
                <p className="text-xs text-gray-300">days</p>
              </div>
            </div>
          )}
        </div>
      </div>
      <Toaster />
    </Card>
  )
}

