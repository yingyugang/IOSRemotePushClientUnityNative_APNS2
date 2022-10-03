using UnityEditor;

public static class CommondLineTest 
{
    public static void BuildIOS()
    {
        BuildPlayerOptions buildPlayerOptions = new BuildPlayerOptions();
        buildPlayerOptions.locationPathName = "iOSBuild";
        buildPlayerOptions.target = BuildTarget.iOS;
        buildPlayerOptions.options = BuildOptions.AcceptExternalModificationsToPlayer;
        BuildPipeline.BuildPlayer(buildPlayerOptions);
    }
}
