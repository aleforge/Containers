#!/bin/bash

#
# Copyright (c) 2021 Matthew Penner
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

# Wait for the container to fully initialize
sleep 1

# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Set environment for Steam Proton
if [ -f "/usr/local/bin/proton" ]; then
    if [ ! -z ${SRCDS_APPID} ]; then
	    mkdir -p /home/container/.steam/steam/steamapps/compatdata/${SRCDS_APPID}
        export STEAM_COMPAT_CLIENT_INSTALL_PATH="/home/container/.steam/steam"
        export STEAM_COMPAT_DATA_PATH="/home/container/.steam/steam/steamapps/compatdata/${SRCDS_APPID}"
    else
        echo -e "----------------------------------------------------------------------------------"
        echo -e "WARNING!!! Proton needs variable SRCDS_APPID, else it will not work. Please add it"
        echo -e "Server stops now"
        echo -e "----------------------------------------------------------------------------------"
        exit 0
        fi
fi

# Switch to the container's working directory
cd /home/container || exit 1

## just in case someone removed the defaults.
if [ "${STEAM_USER}" == "" ]; then
    echo -e "steam user is not set.\n"
    echo -e "Using anonymous user.\n"
    STEAM_USER=anonymous
    STEAM_PASS=""
    STEAM_AUTH=""
else
    echo -e "user set to ${STEAM_USER}"
fi

## if auto_update is not set or to 1 update
if [ -z ${AUTO_UPDATE} ] || [ "${AUTO_UPDATE}" == "1" ]; then 
    # Update Source Server
    if [ ! -z ${SRCDS_APPID} ]; then
	    if [ "${STEAM_USER}" == "anonymous" ]; then
            ./steamcmd/steamcmd.sh +force_install_dir /home/container +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} $( [[ "${WINDOWS_INSTALL}" == "1" ]] && printf %s '+@sSteamCmdForcePlatformType windows' ) +app_update ${SRCDS_APPID} $( [[ -z ${SRCDS_BETAID} ]] || printf %s "-beta ${SRCDS_BETAID}" ) $( [[ -z ${SRCDS_BETAPASS} ]] || printf %s "-betapassword ${SRCDS_BETAPASS}" ) $( [[ -z ${HLDS_GAME} ]] || printf %s "+app_set_config 90 mod ${HLDS_GAME}" ) $( [[ -z ${VALIDATE} ]] || printf %s "validate" ) +quit
	    else
            numactl --physcpubind=+0 ./steamcmd/steamcmd.sh +force_install_dir /home/container +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} $( [[ "${WINDOWS_INSTALL}" == "1" ]] && printf %s '+@sSteamCmdForcePlatformType windows' ) +app_update ${SRCDS_APPID} $( [[ -z ${SRCDS_BETAID} ]] || printf %s "-beta ${SRCDS_BETAID}" ) $( [[ -z ${SRCDS_BETAPASS} ]] || printf %s "-betapassword ${SRCDS_BETAPASS}" ) $( [[ -z ${HLDS_GAME} ]] || printf %s "+app_set_config 90 mod ${HLDS_GAME}" ) $( [[ -z ${VALIDATE} ]] || printf %s "validate" ) +quit
	    fi
    else
        echo -e "No appid set. Starting Server"
    fi

else
    echo -e "Not updating game server as auto update was set to 0. Starting Server"
fi

## Edit Variables
ls -ltr
sed -i "s/RCONEnabled=[a-zA-Z]*/RCONEnabled=True/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
#if [ -n "${ADMIN_PASSWORD}" ]; then
#    sed -i "s/AdminPassword="[a-zA-Z0-9]"*/AdminPassword="$ADMIN_PASSWORD"/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
#fi
if [ -n "${RCON_PORT}" ]; then
    echo "RCON_PORT=${RCON_PORT}"
    sed -i "s/RCONPort=[0-9]*/RCONPort=$RCON_PORT/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${DIFFICULTY}" ]; then
    echo "DIFFICULTY=$DIFFICULTY"
    sed -E -i "s/Difficulty=[a-zA-Z]*/Difficulty=$DIFFICULTY/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${DAYTIME_SPEEDRATE}" ]; then
    echo "DAYTIME_SPEEDRATE=$DAYTIME_SPEEDRATE"
    sed -E -i "s/DayTimeSpeedRate=[+-]?([0-9]*[.])?[0-9]+/DayTimeSpeedRate=$DAYTIME_SPEEDRATE/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${NIGHTTIME_SPEEDRATE}" ]; then
    echo "NIGHTTIME_SPEEDRATE=$NIGHTTIME_SPEEDRATE"
    sed -E -i "s/NightTimeSpeedRate=[+-]?([0-9]*[.])?[0-9]+/NightTimeSpeedRate=$NIGHTTIME_SPEEDRATE/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${EXP_RATE}" ]; then
    echo "EXP_RATE=$EXP_RATE"
    sed -E -i "s/ExpRate=[+-]?([0-9]*[.])?[0-9]+/ExpRate=$EXP_RATE/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PAL_CAPTURE_RATE}" ]; then
    echo "PAL_CAPTURE_RATE=$PAL_CAPTURE_RATE"
    sed -E -i "s/PalCaptureRate=[+-]?([0-9]*[.])?[0-9]+/PalCaptureRate=$PAL_CAPTURE_RATE/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PAL_SPAWN_NUM_RATE}" ]; then
    echo "PAL_SPAWN_NUM_RATE=$PAL_SPAWN_NUM_RATE"
    sed -E -i "s/PalSpawnNumRate=[+-]?([0-9]*[.])?[0-9]+/PalSpawnNumRate=$PAL_SPAWN_NUM_RATE/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PAL_DAMAGE_RATE_ATTACK}" ]; then
    echo "PAL_DAMAGE_RATE_ATTACK=$PAL_DAMAGE_RATE_ATTACK"
    sed -E -i "s/PalDamageRateAttack=[+-]?([0-9]*[.])?[0-9]+/PalDamageRateAttack=$PAL_DAMAGE_RATE_ATTACK/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PAL_DAMAGE_RATE_DEFENSE}" ]; then
    echo "PAL_DAMAGE_RATE_DEFENSE=$PAL_DAMAGE_RATE_DEFENSE"
    sed -E -i "s/PalDamageRateDefense=[+-]?([0-9]*[.])?[0-9]+/PalDamageRateDefense=$PAL_DAMAGE_RATE_DEFENSE/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PLAYER_DAMAGE_RATE_ATTACK}" ]; then
    echo "PLAYER_DAMAGE_RATE_ATTACK=$PLAYER_DAMAGE_RATE_ATTACK"
    sed -E -i "s/PlayerDamageRateAttack=[+-]?([0-9]*[.])?[0-9]+/PlayerDamageRateAttack=$PLAYER_DAMAGE_RATE_ATTACK/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PLAYER_DAMAGE_RATE_DEFENSE}" ]; then
    echo "PLAYER_DAMAGE_RATE_DEFENSE=$PLAYER_DAMAGE_RATE_DEFENSE"
    sed -E -i "s/PlayerDamageRateDefense=[+-]?([0-9]*[.])?[0-9]+/PlayerDamageRateDefense=$PLAYER_DAMAGE_RATE_DEFENSE/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PLAYER_STOMACH_DECREASE_RATE}" ]; then
    echo "PLAYER_STOMACH_DECREASE_RATE=$PLAYER_STOMACH_DECREASE_RATE"
    sed -E -i "s/PlayerStomachDecreaceRate=[+-]?([0-9]*[.])?[0-9]+/PlayerStomachDecreaceRate=$PLAYER_STOMACH_DECREASE_RATE/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PLAYER_STAMINA_DECREASE_RATE}" ]; then
    echo "PLAYER_STAMINA_DECREASE_RATE=$PLAYER_STAMINA_DECREASE_RATE"
    sed -E -i "s/PlayerStaminaDecreaceRate=[+-]?([0-9]*[.])?[0-9]+/PlayerStaminaDecreaceRate=$PLAYER_STAMINA_DECREASE_RATE/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PLAYER_AUTO_HP_REGEN_RATE}" ]; then
    echo "PLAYER_AUTO_HP_REGEN_RATE=$PLAYER_AUTO_HP_REGEN_RATE"
    sed -E -i "s/PlayerAutoHPRegeneRate=[+-]?([0-9]*[.])?[0-9]+/PlayerAutoHPRegeneRate=$PLAYER_AUTO_HP_REGEN_RATE/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PLAYER_AUTO_HP_REGEN_RATE_IN_SLEEP}" ]; then
    echo "PLAYER_AUTO_HP_REGEN_RATE_IN_SLEEP=$PLAYER_AUTO_HP_REGEN_RATE_IN_SLEEP"
    sed -E -i "s/PlayerAutoHpRegeneRateInSleep=[+-]?([0-9]*[.])?[0-9]+/PlayerAutoHpRegeneRateInSleep=$PLAYER_AUTO_HP_REGEN_RATE_IN_SLEEP/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PAL_STOMACH_DECREASE_RATE}" ]; then
    echo "PAL_STOMACH_DECREASE_RATE=$PAL_STOMACH_DECREASE_RATE"
    sed -E -i "s/PalStomachDecreaceRate=[+-]?([0-9]*[.])?[0-9]+/PalStomachDecreaceRate=$PAL_STOMACH_DECREASE_RATE/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PAL_STAMINA_DECREASE_RATE}" ]; then
    echo "PAL_STAMINA_DECREASE_RATE=$PAL_STAMINA_DECREASE_RATE"
    sed -E -i "s/PalStaminaDecreaceRate=[+-]?([0-9]*[.])?[0-9]+/PalStaminaDecreaceRate=$PAL_STAMINA_DECREASE_RATE/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PAL_AUTO_HP_REGEN_RATE}" ]; then
    echo "PAL_AUTO_HP_REGEN_RATE=$PAL_AUTO_HP_REGEN_RATE"
    sed -E -i "s/PalAutoHPRegeneRate=[+-]?([0-9]*[.])?[0-9]+/PalAutoHPRegeneRate=$PAL_AUTO_HP_REGEN_RATE/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PAL_AUTO_HP_REGEN_RATE_IN_SLEEP}" ]; then
    echo "PAL_AUTO_HP_REGEN_RATE_IN_SLEEP=$PAL_AUTO_HP_REGEN_RATE_IN_SLEEP"
    sed -E -i "s/PalAutoHpRegeneRateInSleep=[+-]?([0-9]*[.])?[0-9]+/PalAutoHpRegeneRateInSleep=$PAL_AUTO_HP_REGEN_RATE_IN_SLEEP/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${BUILD_OBJECT_DAMAGE_RATE}" ]; then
    echo "BUILD_OBJECT_DAMAGE_RATE=$BUILD_OBJECT_DAMAGE_RATE"
    sed -E -i "s/BuildObjectDamageRate=[+-]?([0-9]*[.])?[0-9]+/BuildObjectDamageRate=$BUILD_OBJECT_DAMAGE_RATE/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${BUILD_OBJECT_DETERIORATION_DAMAGE_RATE}" ]; then
    echo "BUILD_OBJECT_DETERIORATION_DAMAGE_RATE=$BUILD_OBJECT_DETERIORATION_DAMAGE_RATE"
    sed -E -i "s/BuildObjectDeteriorationDamageRate=[+-]?([0-9]*[.])?[0-9]+/BuildObjectDeteriorationDamageRate=$BUILD_OBJECT_DETERIORATION_DAMAGE_RATE/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${COLLECTION_DROP_RATE}" ]; then
    echo "COLLECTION_DROP_RATE=$COLLECTION_DROP_RATE"
    sed -E -i "s/CollectionDropRate=[+-]?([0-9]*[.])?[0-9]+/CollectionDropRate=$COLLECTION_DROP_RATE/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${COLLECTION_OBJECT_HP_RATE}" ]; then
    echo "COLLECTION_OBJECT_HP_RATE=$COLLECTION_OBJECT_HP_RATE"
    sed -E -i "s/CollectionObjectHpRate=[+-]?([0-9]*[.])?[0-9]+/CollectionObjectHpRate=$COLLECTION_OBJECT_HP_RATE/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${COLLECTION_OBJECT_RESPAWN_SPEED_RATE}" ]; then
    echo "COLLECTION_OBJECT_RESPAWN_SPEED_RATE=$COLLECTION_OBJECT_RESPAWN_SPEED_RATE"
    sed -E -i "s/CollectionObjectRespawnSpeedRate=[+-]?([0-9]*[.])?[0-9]+/CollectionObjectRespawnSpeedRate=$COLLECTION_OBJECT_RESPAWN_SPEED_RATE/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${ENEMY_DROP_ITEM_RATE}" ]; then
    echo "ENEMY_DROP_ITEM_RATE=$ENEMY_DROP_ITEM_RATE"
    sed -E -i "s/EnemyDropItemRate=[+-]?([0-9]*[.])?[0-9]+/EnemyDropItemRate=$ENEMY_DROP_ITEM_RATE/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${DEATH_PENALTY}" ]; then
    echo "DEATH_PENALTY=$DEATH_PENALTY"
    sed -E -i "s/DeathPenalty=[a-zA-Z]*/DeathPenalty=$DEATH_PENALTY/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${ENABLE_PLAYER_TO_PLAYER_DAMAGE}" ]; then
    echo "ENABLE_PLAYER_TO_PLAYER_DAMAGE=$ENABLE_PLAYER_TO_PLAYER_DAMAGE"
    sed -E -i "s/bEnablePlayerToPlayerDamage=[a-zA-Z]*/bEnablePlayerToPlayerDamage=$ENABLE_PLAYER_TO_PLAYER_DAMAGE/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${ENABLE_FRIENDLY_FIRE}" ]; then
    echo "ENABLE_FRIENDLY_FIRE=$ENABLE_FRIENDLY_FIRE"
    sed -E -i "s/bEnableFriendlyFire=[a-zA-Z]*/bEnableFriendlyFire=$ENABLE_FRIENDLY_FIRE/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${ENABLE_INVADER_ENEMY}" ]; then
    echo "ENABLE_INVADER_ENEMY=$ENABLE_INVADER_ENEMY"
    sed -E -i "s/bEnableInvaderEnemy=[a-zA-Z]*/bEnableInvaderEnemy=$ENABLE_INVADER_ENEMY/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${ACTIVE_UNKO}" ]; then
    echo "ACTIVE_UNKO=$ACTIVE_UNKO"
    sed -E -i "s/bActiveUNKO=[a-zA-Z]*/bActiveUNKO=$ACTIVE_UNKO/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${ENABLE_AIM_ASSIST_PAD}" ]; then
    echo "ENABLE_AIM_ASSIST_PAD=$ENABLE_AIM_ASSIST_PAD"
    sed -E -i "s/bEnableAimAssistPad=[a-zA-Z]*/bEnableAimAssistPad=$ENABLE_AIM_ASSIST_PAD/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${ENABLE_AIM_ASSIST_KEYBOARD}" ]; then
    echo "ENABLE_AIM_ASSIST_KEYBOARD=$ENABLE_AIM_ASSIST_KEYBOARD"
    sed -E -i "s/bEnableAimAssistKeyboard=[a-zA-Z]*/bEnableAimAssistKeyboard=$ENABLE_AIM_ASSIST_KEYBOARD/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${DROP_ITEM_MAX_NUM}" ]; then
    echo "DROP_ITEM_MAX_NUM=$DROP_ITEM_MAX_NUM"
    sed -E -i "s/DropItemMaxNum=[0-9]*/DropItemMaxNum=$DROP_ITEM_MAX_NUM/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${DROP_ITEM_MAX_NUM_UNKO}" ]; then
    echo "DROP_ITEM_MAX_NUM_UNKO=$DROP_ITEM_MAX_NUM_UNKO"
    sed -E -i "s/DropItemMaxNum_UNKO=[0-9]*/DropItemMaxNum_UNKO=$DROP_ITEM_MAX_NUM_UNKO/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${BASE_CAMP_MAX_NUM}" ]; then
    echo "BASE_CAMP_MAX_NUM=$BASE_CAMP_MAX_NUM"
    sed -E -i "s/BaseCampMaxNum=[0-9]*/BaseCampMaxNum=$BASE_CAMP_MAX_NUM/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${BASE_CAMP_WORKER_MAXNUM}" ]; then
    echo "BASE_CAMP_WORKER_MAXNUM=$BASE_CAMP_WORKER_MAXNUM"
    sed -E -i "s/BaseCampWorkerMaxNum=[0-9]*/BaseCampWorkerMaxNum=$BASE_CAMP_WORKER_MAXNUM/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${DROP_ITEM_ALIVE_MAX_HOURS}" ]; then
    echo "DROP_ITEM_ALIVE_MAX_HOURS=$DROP_ITEM_ALIVE_MAX_HOURS"
    sed -E -i "s/DropItemAliveMaxHours=[+-]?([0-9]*[.])?[0-9]+/DropItemAliveMaxHours=$DROP_ITEM_ALIVE_MAX_HOURS/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${AUTO_RESET_GUILD_NO_ONLINE_PLAYERS}" ]; then
    echo "AUTO_RESET_GUILD_NO_ONLINE_PLAYERS=$AUTO_RESET_GUILD_NO_ONLINE_PLAYERS"
    sed -E -i "s/bAutoResetGuildNoOnlinePlayers=[a-zA-Z]*/bAutoResetGuildNoOnlinePlayers=$AUTO_RESET_GUILD_NO_ONLINE_PLAYERS/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS}" ]; then
    echo "AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS=$AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS"
    sed -E -i "s/AutoResetGuildTimeNoOnlinePlayers=[+-]?([0-9]*[.])?[0-9]+/AutoResetGuildTimeNoOnlinePlayers=$AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${GUILD_PLAYER_MAX_NUM}" ]; then
    echo "GUILD_PLAYER_MAX_NUM=$GUILD_PLAYER_MAX_NUM"
    sed -E -i "s/GuildPlayerMaxNum=[0-9]*/GuildPlayerMaxNum=$GUILD_PLAYER_MAX_NUM/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PAL_EGG_DEFAULT_HATCHING_TIME}" ]; then
    echo "PAL_EGG_DEFAULT_HATCHING_TIME=$PAL_EGG_DEFAULT_HATCHING_TIME"
    sed -E -i "s/PalEggDefaultHatchingTime=[+-]?([0-9]*[.])?[0-9]+/PalEggDefaultHatchingTime=$PAL_EGG_DEFAULT_HATCHING_TIME/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${WORK_SPEED_RATE}" ]; then
    echo "WORK_SPEED_RATE=$WORK_SPEED_RATE"
    sed -E -i "s/WorkSpeedRate=[+-]?([0-9]*[.])?[0-9]+/WorkSpeedRate=$WORK_SPEED_RATE/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP}" ]; then
    echo "CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP=$CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP"
    sed -E -i "s/bCanPickupOtherGuildDeathPenaltyDrop=[a-zA-Z]*/bCanPickupOtherGuildDeathPenaltyDrop=$CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${ENABLE_NON_LOGIN_PENALTY}" ]; then
    echo "ENABLE_NON_LOGIN_PENALTY=$ENABLE_NON_LOGIN_PENALTY"
    sed -E -i "s/bEnableNonLoginPenalty=[a-zA-Z]*/bEnableNonLoginPenalty=$ENABLE_NON_LOGIN_PENALTY/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${ENABLE_FAST_TRAVEL}" ]; then
    echo "ENABLE_FAST_TRAVEL=$ENABLE_FAST_TRAVEL"
    sed -E -i "s/bEnableFastTravel=[a-zA-Z]*/bEnableFastTravel=$ENABLE_FAST_TRAVEL/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${IS_START_LOCATION_SELECT_BY_MAP}" ]; then
    echo "IS_START_LOCATION_SELECT_BY_MAP=$IS_START_LOCATION_SELECT_BY_MAP"
    sed -E -i "s/bIsStartLocationSelectByMap=[a-zA-Z]*/bIsStartLocationSelectByMap=$IS_START_LOCATION_SELECT_BY_MAP/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${EXIST_PLAYER_AFTER_LOGOUT}" ]; then
    echo "EXIST_PLAYER_AFTER_LOGOUT=$EXIST_PLAYER_AFTER_LOGOUT"
    sed -E -i "s/bExistPlayerAfterLogout=[a-zA-Z]*/bExistPlayerAfterLogout=$EXIST_PLAYER_AFTER_LOGOUT/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${ENABLE_DEFENSE_OTHER_GUILD_PLAYER}" ]; then
    echo "ENABLE_DEFENSE_OTHER_GUILD_PLAYER=$ENABLE_DEFENSE_OTHER_GUILD_PLAYER"
    sed -E -i "s/bEnableDefenseOtherGuildPlayer=[a-zA-Z]*/bEnableDefenseOtherGuildPlayer=$ENABLE_DEFENSE_OTHER_GUILD_PLAYER/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${COOP_PLAYER_MAX_NUM}" ]; then
    echo "COOP_PLAYER_MAX_NUM=$COOP_PLAYER_MAX_NUM"
    sed -E -i "s/CoopPlayerMaxNum=[0-9]*/CoopPlayerMaxNum=$COOP_PLAYER_MAX_NUM/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${REGION}" ]; then
    echo "REGION=$REGION"
    sed -E -i "s/Region=\"[^\"]*\"/Region=\"$REGION\"/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${USEAUTH}" ]; then
    echo "USEAUTH=$USEAUTH"
    sed -E -i "s/bUseAuth=[a-zA-Z]*/bUseAuth=$USEAUTH/" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${BAN_LIST_URL}" ]; then
    echo "BAN_LIST_URL=$BAN_LIST_URL"
    sed -E -i "s~BanListURL=\"[^\"]*\"~BanListURL=\"$BAN_LIST_URL\"~" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PREDATOR_BOSS}" ]; then
    echo "EnablePredatorBossPal=$PREDATOR_BOSS"
    sed -E -i "s~EnablePredatorBossPal=\"[^\"]*\"~EnablePredatorBossPal=\"$PREDATOR_BOSS\"~" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${HARDCORE}" ]; then
    echo "bHardcore=$HARDCORE"
    sed -E -i "s~bHardcore=\"[^\"]*\"~bHardcore=\"$HARDCORE\"~" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${LOST_PAL}" ]; then
    echo "bPalLost=$LOST_PAL"
    sed -E -i "s~bPalLost=\"[^\"]*\"~bPalLost=\"$LOST_PAL\"~" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${BUILD_LIMIT}" ]; then
    echo "bBuildAreaLimit=$BUILD_LIMIT"
    sed -E -i "s~bBuildAreaLimit=\"[^\"]*\"~bBuildAreaLimit=\"$BUILD_LIMIT\"~" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${ITEM_WEIGHT}" ]; then
    echo "ItemWeightRate=$ITEM_WEIGHT"
    sed -E -i "s~ItemWeightRate=\"[^\"]*\"~ItemWeightRate=\"$ITEM_WEIGHT\"~" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${BUILDING_LIMIT}" ]; then
    echo "MaxBuildingLimitNum=$BUILDING_LIMIT"
    sed -E -i "s~MaxBuildingLimitNum=\"[^\"]*\"~MaxBuildingLimitNum=\"$BUILDING_LIMIT\"~" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${RANDOMIZER_TYPE}" ]; then
    echo "RandomizerType=$RANDOMIZER_TYPE"
    sed -E -i "s~RandomizerType=\"[^\"]*\"~RandomizerType=\"$RANDOMIZER_TYPE\"~" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${SEED}" ]; then
    echo "RandomizerSeed=$SEED"
    sed -E -i "s~RandomizerSeed=\"[^\"]*\"~RandomizerSeed=\"$SEED\"~" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${BUILD_HEALTH_OBJECT}" ]; then
    echo "BuildObjectHpRate=$BUILD_HEALTH_OBJECT"
    sed -E -i "s~BuildObjectHpRate=\"[^\"]*\"~BuildObjectHpRate=\"$BUILD_HEALTH_OBJECT\"~" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${CULL_DISTANCE}" ]; then
    echo "ServerReplicatePawnCullDistance=$CULL_DISTANCE"
    sed -E -i "s~ServerReplicatePawnCullDistance=\"[^\"]*\"~ServerReplicatePawnCullDistance=\"$CULL_DISTANCE\"~" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${CHAT_LIMIT}" ]; then
    echo "ChatPostLimitPerMinute=$CHAT_LIMIT"
    sed -E -i "s~ChatPostLimitPerMinute=\"[^\"]*\"~ChatPostLimitPerMinute=\"$CHAT_LIMIT\"~" Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi

# Replace Startup Variables
MODIFIED_STARTUP=$(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}