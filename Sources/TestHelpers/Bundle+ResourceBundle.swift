import Foundation

extension Bundle {
    /// Returns the GravatarTests Bundle.
    class var testsBundle: Bundle {
        Bundle.module
    }
}

extension Bundle {
    func jsonData(forResource resource: String) -> Data {
        let url = Bundle.testsBundle.url(forResource: resource, withExtension: "json")!
        do {
            return try Data(contentsOf: url)
        } catch {
            fatalError("Could not load JSON file at \(url). \(error)")
        }
    }

    public static var fullProfileJsonData: Data {
        testsBundle.jsonData(forResource: "fullProfile")
    }

    public static var imageUploadJsonData: Data? {
        testsBundle.jsonData(forResource: "avatarUploadResponse")
    }

    public static var setRatingJsonData: Data {
        testsBundle.jsonData(forResource: "avatarSetRatingResponse")
    }

    public static var setAltTextJsonData: Data {
        testsBundle.jsonData(forResource: "avatarSetAltTextResponse")
    }

    public static var getAvatarsJsonData: Data {
        testsBundle.jsonData(forResource: "avatarsResponse")
    }

    public static var postAvatarSelectedJsonData: Data {
        testsBundle.jsonData(forResource: "avatarSelected")
    }

    public static var postAvatarUploadJsonData: Data {
        testsBundle.jsonData(forResource: "avatarSelected")
    }
}
