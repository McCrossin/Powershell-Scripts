$InputValue = read-host -Prompt "Input: "

$inputValue = $InputValue.ToLower()
switch ($InputValue) {
    { $_ -in "yes", "y" } { "Do Stuff" }
    Default { "If not yes do other stuff" }
}