import Foundation

@c
public func vision_ocrmac_recognize(_ path: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
    let pathStr = String(cString: path)
    let result = performRecognize(path: pathStr)
    return strdup(result)!
}

@c
public func vision_ocrmac_free(_ ptr: UnsafeMutablePointer<CChar>?) {
    free(ptr)
}
