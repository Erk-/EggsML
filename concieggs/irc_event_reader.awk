# Requires GNU awk.

BEGIN {
  name = ENVIRON["CONCIEGGS_DEFAULT_NAME"]
  error_channel = ENVIRON["CONCIEGGS_ERROR_CHANNEL"]
  default_channel = ENVIRON["CONCIEGGS_DEFAULT_CHANNEL"]
  event_channel="#diku"
}

function shellquote(str) {
  gsub(/'/, "'\\''", str)
  return sprintf("'%s'", str)
}

# Valid IRC message at all?
{
  context=0
  timestamp=0
  payload=0
  message_from=0
  message_body=0
  server_message_code=0
  if (match($0, /^([^ ']+) *: ([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:[0-9][0-9]) (.*)$/, matches)) {
    context=matches[1]
    timestamp=matches[2]
    payload=matches[3]
  } else if (match($0, /tick/)) {
    system(setvars "\n" "runFor \"$EGGS_WHERE\" checkReminders")
    next
  } else if (match($0, /^BEGIVENHED (.*)$/, matches)) {
    message_body=matches[1]
    system("export EGGS_WHERE=" shellquote(event_channel)  "\n" \
           "export EGGS_BODY="  shellquote(message_body)   "\n" \
           "runFor \"$EGGS_WHERE\" printCal")
    next
  } else {
    # Invalid.
    next
  }
}

# Server message?
match(payload, /^>< ([0-9][0-9][0-9]) \(([^)]*)\): (.*)$/, matches) {
  server_message_code=matches[1]
  server_message_arg=matches[2]
  server_message_body=matches[3]
  if (server_message_code == "001") {
    # We just (re)?connected.
    system("export EGGS_USER=" shellquote(context) "\n"                 \
           "export EGGS_WHERE=" shellquote(shell_message_body) "\n"     \
           "export CONCIEGGS_NAME=" shellquote(name) "\n"                    \
           "runFor \"$EGGS_WHERE\" runHooks server_connect")
    name = ENVIRON["CONCIEGGS_DEFAULT_NAME"]
  }
}

# Did my name change?
match(payload, /^>< NICK \(\): ([^ ]+)/, matches) && context == name {
  name = matches[1]
}

# Quit action?
match(payload, /^>< QUIT \(\): (.*)$/, matches) {
  quitter=context
  reason=matches[1]
  default_channel="#diku"
  system("export EGGS_USER=" shellquote(quitter)          "\n" \
         "export EGGS_WHERE=" shellquote(default_channel) "\n" \
         "export EGGS_BODY=" shellquote(reason)           "\n" \
         "export CONCIEGGS_NAME=" shellquote(name)        "\n" \
         "runFor \"$EGGS_WHERE\" runHooks quit")
}

# Part action?
match(payload, /^>< (PART|JOIN) \(([^)]+)\): (.*)$/, matches) {
  action=matches[1]
  partedUser=context # yes
  parted_channel=matches[2]
  partedReason=matches[3]
  if (action == "PART") {
    runHooks="runHooks channel_part"
  } else {
    runHooks="runHooks channel_join"
  }
  system("export EGGS_USER=" shellquote(context) "\n"   \
         "export EGGS_WHERE=" shellquote(parted_channel) "\n"           \
         "export CONCIEGGS_NAME=" shellquote(name) "\n"                      \
         "export EGGS_BODY=" shellquote(partedReason) "\n"              \
         "runFor \"$EGGS_WHERE\" " runHooks )
}

# Channel/private message?
match(payload, /^<([^ ]+)> (.*)$/, matches) {
  message_from=matches[1]
  message_body=matches[2]
  if (message_from == name) {
    next
  }
  setvars=("export EGGS_USER=" shellquote(message_from) "\n"            \
           "export EGGS_WHERE=" shellquote(context) "\n"                \
           "export EGGS_WHEN=" shellquote(timestamp) "\n"               \
           "export CONCIEGGS_NAME=" shellquote(name) "\n"                    \
           "export EGGS_BODY=" shellquote(message_body) "\n"            \
           "export EGGS_LINE=" shellquote($0) "\n")
  if (match(context, /^#/)) {
    system(setvars "\n" "runFor \"$EGGS_WHERE\" runHooks channel_message")
  } else {
    system(setvars "\n" "runFor \"$EGGS_USER\" runHooks private_message")
  }
}
