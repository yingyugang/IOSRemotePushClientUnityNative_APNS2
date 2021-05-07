using System.IO;
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.iOS.Xcode;

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
    }
}
