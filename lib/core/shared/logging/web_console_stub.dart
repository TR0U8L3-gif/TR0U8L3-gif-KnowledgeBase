/// Non-web stub — all functions are no-ops.
/// On web the real implementation in web_console.dart is used instead
/// via the conditional import in app_logger.dart.

bool isDebugEnabled() => false;

void writeLog(String msg) {}
void writeInfo(String msg) {}
void writeWarn(String msg) {}
void writeError(String msg) {}

void registerDebugCommands() {}
