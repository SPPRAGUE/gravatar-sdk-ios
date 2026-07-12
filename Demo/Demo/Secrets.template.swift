// Template for the app's secrets.
//
// Only edit this file if `Secrets` needs to change in the app.
//
// External contributors: The first build copies this file to the .gitignored `Demo/Demo/Secrets.external-contributors.swift`.
// Edit that file with your own credentials from https://gravatar.com/developers/applications.
// Otherwise the app will build with the empty defaults below.
//
// Internal contributors: Run `make setup-secrets` before building to decrypt the first-party secrets instead.

struct Secrets {
    static let apiKey: String? = nil
    static let clientID: String = ""
    static let redirectURI: String = ""
}
