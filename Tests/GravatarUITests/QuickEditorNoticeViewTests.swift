@testable import GravatarUI
import SnapshotTesting
import Testing

@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
struct QuickEditorNoticeViewTests {
    @MainActor
    @Test
    func testQuickEditorNoticeView() async throws {
        let view = QuickEditorNoticeView(
            email: .init("some@email.com"),
            token: .constant("atoken"),
            oauthError: .constant(nil),
            model: .init(
                email: .init("some@email.com"),
                authToken: "atoken"
            ),
            safariURL: .constant(nil),
            proceedAction: {}
        ).frame(width: ViewImageConfig.iPhoneSe.size?.width ?? 0)

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .device(config: .iPhoneSe)),
                .testStrategy(userInterfaceStyle: .dark, layout: .device(config: .iPhoneSe)),
            ]
        )
    }

    @MainActor
    @Test
    func testQuickEditorNoticeViewWithoutToken() async throws {
        let view = QuickEditorNoticeView(
            email: .init("some@email.com"),
            token: .constant(nil),
            oauthError: .constant(nil),
            model: .init(
                email: .init("some@email.com"),
                authToken: nil
            ),
            safariURL: .constant(nil),
            proceedAction: {}
        ).frame(width: ViewImageConfig.iPhoneSe.size?.width ?? 0)

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .device(config: .iPhoneSe)),
                .testStrategy(userInterfaceStyle: .dark, layout: .device(config: .iPhoneSe)),
            ]
        )
    }

    @MainActor
    @Test
    func testQuickEditorNoticeViewWithError() async throws {
        let view = QuickEditorNoticeView(
            email: .init("some@email.com"),
            token: .constant(nil),
            oauthError: .constant(OAuthError.loggedInWithWrongEmail(email: "wrong@email.com")),
            model: .init(
                email: .init("some@email.com"),
                authToken: "atoken"
            ),
            safariURL: .constant(nil),
            proceedAction: {}
        ).frame(width: ViewImageConfig.iPhoneSe.size?.width ?? 0)

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .device(config: .iPhoneSe)),
                .testStrategy(userInterfaceStyle: .dark, layout: .device(config: .iPhoneSe)),
            ]
        )
    }
}
