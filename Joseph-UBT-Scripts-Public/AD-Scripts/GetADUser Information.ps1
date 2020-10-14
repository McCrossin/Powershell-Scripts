$filename = "Groups.csv"
Get-ADUser -Filter * -Properties GivenName, Surname, City, State, Country, Title, Department, Company, Manager | Export-Csv -Path C:\Git\Joseph-UBT-Scripts\AD-Scripts\ADUserList
