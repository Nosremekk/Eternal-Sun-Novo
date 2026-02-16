// Feather disable all

/// Returns `true` if the current platform supports gyro and motion. Platforms that support gyro:
/// - Windows & Linux, if Steam is open and Steamworks has been implemented in the game
/// - PlayStation 4 & PlayStation 5
/// - Nintendo Switch

function InputMotionSupportedByPlatform()
{
    static _result = ((INPUT_ON_SWITCH or INPUT_ON_PS4 or INPUT_ON_PS5)
                  or  ((INPUT_ON_WINDOWS or INPUT_ON_LINUX) and InputGetSteamInfo(INPUT_STEAM_INFO.STEAMWORKS)));
    
    return _result;
}