// Template for the app's secrets.
//
// Only edit this file if `Secrets` needs to change in the app.
//
// External contributors: Copy this file to the .gitignored `Demo/Demo/Secrets.external-contributors.swift`,
// then fill it in with your own credentials from https://gravatar.com/developers/applications.
// The build fails until that file exists.
//
// Internal contributors: Run `make setup-secrets` before building to decrypt the first-party secrets instead.

struct Secrets {
    static let apiKey: String? = nil
    static let clientID: String = ""
    static let redirectURI: String = ""
}
