using System.IO;
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.iOS.Xcode;
using UnityEditor.iOS.Xcode.Extensions;
using UnityEngine;

public class iOSNotificationBuild 
{
    [PostProcessBuild]
    public static void OnPostprocessBuild(BuildTarget buildTarget, string path)
    {
        if (buildTarget != BuildTarget.iOS)
            return;
        var pbxProjectPath = PBXProject.GetPBXProjectPath(path);
        var pbxProject = new PBXProject();
        pbxProject.ReadFromString(File.ReadAllText(pbxProjectPath));
        string mainTarget;
        string unityFrameworkTarget;
        var unityMainTargetGuidMethod = pbxProject.GetType().GetMethod("GetUnityMainTargetGuid");
        var unityFrameworkTargetGuidMethod = pbxProject.GetType().GetMethod("GetUnityFrameworkTargetGuid");
        if (unityMainTargetGuidMethod != null && unityFrameworkTargetGuidMethod != null)
        {
            mainTarget = (string)unityMainTargetGuidMethod.Invoke(pbxProject, null);
            unityFrameworkTarget = (string)unityFrameworkTargetGuidMethod.Invoke(pbxProject, null);
        }
        else
        {
            mainTarget = pbxProject.TargetGuidByName("Unity-iPhone");
            unityFrameworkTarget = mainTarget;
        }
        pbxProject.AddFrameworkToProject(unityFrameworkTarget, "UserNotifications.framework", true);
        File.WriteAllText(pbxProjectPath, pbxProject.WriteToString());
        var entitlementsFileName = pbxProject.GetBuildPropertyForAnyConfig(mainTarget, "CODE_SIGN_ENTITLEMENTS");
        if (entitlementsFileName == null)
        {
            var bundleIdentifier = PlayerSettings.GetApplicationIdentifier(BuildTargetGroup.iOS);
            entitlementsFileName = string.Format("{0}.entitlements", bundleIdentifier.Substring(bundleIdentifier.LastIndexOf(".") + 1));
        }

        var capManager = new ProjectCapabilityManager(pbxProjectPath, entitlementsFileName, "Unity-iPhone");
        capManager.AddPushNotifications(true);
        capManager.WriteToFile();
        var plistPath = path + "/Info.plist";
        var plist = new PlistDocument();
        plist.ReadFromString(File.ReadAllText(plistPath));
        var rootDict = plist.root;
        PlistElementArray currentBacgkgroundModes = (PlistElementArray)rootDict["UIBackgroundModes"];
        if (currentBacgkgroundModes == null)
            currentBacgkgroundModes = rootDict.CreateArray("UIBackgroundModes");
        currentBacgkgroundModes.AddString("remote-notification");
        File.WriteAllText(plistPath, plist.WriteToString());

        // Notification Service ExtensionをXcodeプロジェクトに追加する処理
        // iOSフォルダに必要なものを追加
        if (!Directory.Exists(path + "/Notification"))
        {
            Directory.CreateDirectory(path + "/Notification");
        }
        var rootDir = Directory.GetParent(Application.dataPath).ToString();
        File.Copy(rootDir + "/NotifyEX/NotificationService.swift", path + "/NotifyEX/NotificationService.swift");
        File.Copy(rootDir + "/NotifyEX/Info.plist", path + "/NotifyEX/Info.plist");
        // XcodeプロジェクトNotification Service Extensionのtargetを追加する
        string targetGUID = pbxProject.GetUnityMainTargetGuid();
        var pathToNotificationService = path + "/NotifyEX";
        var notificationServicePlistPath = "NotifyEX/Info.plist";
        PlistDocument notificationServicePlist = new PlistDocument();
        notificationServicePlist.ReadFromFile(notificationServicePlistPath);
        notificationServicePlist.root.SetString("CFBundleShortVersionString", PlayerSettings.bundleVersion);
        notificationServicePlist.root.SetString("CFBundleVersion", PlayerSettings.iOS.buildNumber.ToString());
        var notificationServiceTarget = PBXProjectExtensions.AddAppExtension(pbxProject, targetGUID, "Notification", PlayerSettings.GetApplicationIdentifier(BuildTargetGroup.iOS) + ".Notification", notificationServicePlistPath);
        // Notification Service Extensionのtargetで使用するファイルをXcodeプロジェクトに追加する
        pbxProject.AddFile(pathToNotificationService + "/Info.plist", "NotifyEX/Info.plist");
        //pbxProject.AddFile(pathToNotificationService + "/NotificationService.swift", "/NotifyEX/NotificationService.swift");
        pbxProject.AddFileToBuild(notificationServiceTarget, pbxProject.AddFile(pathToNotificationService + "/NotificationService.swift", "/NotifyEX/NotificationService.swift"));
        // Notification Service Extensionに必要な設定を追加する
        pbxProject.SetBuildProperty(notificationServiceTarget, "ARCHS", "$(ARCHS_STANDARD)");
        pbxProject.SetBuildProperty(notificationServiceTarget, "DEVELOPMENT_TEAM", PlayerSettings.iOS.appleDeveloperTeamID);
        pbxProject.SetBuildProperty(notificationServiceTarget, "TARGETED_DEVICE_FAMILY", "1,2");
        pbxProject.SetBuildProperty(notificationServiceTarget, "GCC_C_LANGUAGE_STANDARD", "gnu11");
        pbxProject.SetBuildProperty(notificationServiceTarget, "CLANG_CXX_LANGUAGE_STANDARD", "gnu++14");
        pbxProject.SetBuildProperty(notificationServiceTarget, "CLANG_CXX_LIBRARY", "libc++");
        pbxProject.SetBuildProperty(notificationServiceTarget, "CLANG_ENABLE_MODULES", "YES");
        pbxProject.SetBuildProperty(notificationServiceTarget, "ALWAYS_SEARCH_USER_PATHS", "NO");
        // Xcodeプロジェクトに書き込む
        notificationServicePlist.WriteToFile(notificationServicePlistPath);
        pbxProject.WriteToFile(path);
    }
}
