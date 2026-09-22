import AVFoundation
// usage: verify <file.mp4> <code1,code2,...>  -> exits 1 if any app language code matches no caption track
let asset = AVURLAsset(url: URL(fileURLWithPath: CommandLine.arguments[1]))
let codes = CommandLine.arguments[2].split(separator: ",").map(String.init)
guard let group = asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else { print("FAIL: no legible group"); exit(1) }
var failed = false
for code in codes {
    let opts = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: Locale(identifier: code))
    let got = opts.first?.extendedLanguageTag ?? "NONE"
    if opts.isEmpty || got != code { print("  MISMATCH \(code) -> \(got)"); failed = true }
}
print(failed ? "FAIL" : "OK: \(codes.count) languages resolve, \(group.options.count) options")
exit(failed ? 1 : 0)
