# Copilot Instructions for NoGrenadeRinging SourceMod Plugin

## Repository Overview

This repository contains a SourceMod plugin for Source engine games (CS:GO, CS:S) that blocks the annoying ringing noise effect when grenades explode near players. The plugin uses DHooks to intercept the `OnDamagedByExplosion` function and prevent the audio effect.

### Key Files
- `addons/sourcemod/scripting/NoGrenadeRinging.sp` - Main plugin source code
- `addons/sourcemod/gamedata/NoGrenadeRinging.games.txt` - Game-specific offsets for CS:GO and CS:S
- `sourceknight.yaml` - Build configuration for SourceKnight build system
- `.github/workflows/ci.yml` - CI/CD pipeline configuration

## Technical Environment

### Language & Platform
- **Language**: SourcePawn (SourceMod's scripting language)
- **Platform**: SourceMod 1.11.0+ (currently using 1.11.0-git6934)
- **Target Games**: Counter-Strike: Global Offensive, Counter-Strike: Source
- **Build System**: SourceKnight 0.2 (not direct spcomp compilation)

### Dependencies
- SourceMod API (automatically included)
- DHooks extension for function hooking
- SDKTools for game entity manipulation

## Build System

### SourceKnight Configuration
This repository uses SourceKnight instead of direct SourcePawn compiler (spcomp). Key configuration in `sourceknight.yaml`:

```yaml
project:
  sourceknight: 0.2
  name: NoGrenadeRinging
  dependencies:
    - name: sourcemod
      type: tar
      version: 1.11.0-git6934
      location: https://sm.alliedmods.net/smdrop/1.11/sourcemod-1.11.0-git6934-linux.tar.gz
  root: /
  output: /addons/sourcemod/plugins
  targets:
    - NoGrenadeRinging
```

### Build Commands
- **Local Build**: Use SourceKnight CLI or GitHub Actions
- **CI Build**: GitHub Actions automatically builds on push/PR using `maxime1907/action-sourceknight@v1`
- **Output**: Compiled `.smx` files in `/addons/sourcemod/plugins/`

### Artifact Structure
The CI creates packages with:
- `common/addons/sourcemod/plugins/` - Compiled plugins
- `common/addons/sourcemod/gamedata/` - Game data files

## Code Style & Standards

### SourcePawn Conventions
```sourcepawn
#pragma semicolon 1          // Enforce semicolons
#pragma newdecls required    // Use new variable declaration syntax

// Variable naming
Handle g_hVariableName;      // Global handles with g_h prefix
int g_iClientData[MAXPLAYERS+1]; // Global arrays with g_ prefix
bool g_bPluginEnabled;       // Global booleans with g_b prefix

// Function naming
public void OnPluginStart()  // PascalCase for public functions
void MyInternalFunction()    // PascalCase for internal functions

// Local variables
int clientIndex;             // camelCase for local variables
bool isEnabled;              // camelCase for parameters
```

### Memory Management
```sourcepawn
// Preferred modern approach
delete handleVar;            // Direct delete, no null check needed

// Avoid legacy patterns (currently used in this plugin)
if(handleVar != null)        // Don't check for null before delete
{
    CloseHandle(handleVar);  // Use delete instead of CloseHandle
    handleVar = null;
}

// Current plugin uses legacy pattern:
CloseHandle(hTemp);          // Should be: delete hTemp;

// StringMap/ArrayList
delete g_hStringMap;         // Delete and recreate instead of Clear()
g_hStringMap = new StringMap();
```

### Code Modernization Opportunities
The current plugin code uses some legacy SourcePawn patterns that should be updated:
- `CloseHandle(hTemp)` → `delete hTemp`
- Consider adding `#pragma newdecls required` directive
- Add proper cleanup in `OnPluginEnd()` function

### DHooks Patterns
```sourcepawn
// Global hook handle
Handle g_hDamagedByExplosion;

// Setup in OnPluginStart
Handle hTemp = LoadGameConfigFile("NoGrenadeRinging.games");
int Offset = GameConfGetOffset(hTemp, "OnDamagedByExplosion");
g_hDamagedByExplosion = DHookCreate(Offset, HookType_Entity, ReturnType_Int, ThisPointer_CBaseEntity, OnDamagedByExplosion);
DHookAddParam(g_hDamagedByExplosion, HookParamType_ObjectPtr);
delete hTemp;

// Hook entities
DHookEntity(g_hDamagedByExplosion, false, client);

// Hook callback
public MRESReturn OnDamagedByExplosion(int pThis, Handle hReturn, Handle hParams)
{
    DHookSetReturn(hReturn, 0);
    return MRES_Supercede;
}
```

## Game Data Management

### Offset Configuration
Game data files contain platform-specific offsets for hooking functions:

```
"Games"
{
    "csgo"
    {
        "Offsets"
        {
            "OnDamagedByExplosion"
            {
                "windows"    "376"
                "linux"      "377"
                "mac"        "377"
            }
        }
    }
}
```

### Updating Offsets
- **Game Updates**: Offsets may change with game updates
- **Verification**: Use tools like IDA Pro, Ghidra, or game-specific tools
- **Testing**: Always test on development servers before deployment
- **Multi-Platform**: Ensure offsets work on Windows, Linux, and Mac

## Project Structure & Best Practices

### Directory Layout
```
addons/sourcemod/
├── scripting/
│   └── NoGrenadeRinging.sp          # Main plugin source
├── gamedata/
│   └── NoGrenadeRinging.games.txt   # Game-specific data
└── plugins/                         # Compiled output (not in repo)
    └── NoGrenadeRinging.smx
```

### Plugin Structure
```sourcepawn
#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <dhooks>

// Global variables
Handle g_hDamagedByExplosion;

// Plugin info
public Plugin myinfo = {
    name        = "NoGrenadeRinging",
    author      = "BotoX",
    description = "Block the annoying ringing noise when a grenade explodes next to you",
    version     = "1.1.0",
    url         = ""
};

// Core functions
public void OnPluginStart() { }
public void OnClientPutInServer(int client) { }
public MRESReturn OnDamagedByExplosion(int pThis, Handle hReturn, Handle hParams) { }
```

### Error Handling
```sourcepawn
// Game config validation
Handle hTemp = LoadGameConfigFile("NoGrenadeRinging.games");
if(hTemp == INVALID_HANDLE)
    SetFailState("Why you no has gamedata?");

// Client validation
if(!IsClientInGame(client))
    return;

// Hook validation  
if(g_hDamagedByExplosion == INVALID_HANDLE)
    return;
```

## Testing & Validation

### No Automated Tests
This repository doesn't have automated tests. For manual testing:

1. **Compilation Test**: Ensure plugin compiles without errors
2. **Load Test**: Verify plugin loads on test server
3. **Functionality Test**: Test grenade explosion effects
4. **Memory Test**: Check for memory leaks using SourceMod profiler

### Manual Testing Process
```bash
# 1. Build the plugin
# Use GitHub Actions or SourceKnight locally

# 2. Deploy to test server
# Copy .smx to addons/sourcemod/plugins/
# Copy .txt to addons/sourcemod/gamedata/

# 3. Load plugin
sm plugins load NoGrenadeRinging

# 4. Test functionality
# Throw grenades near players and verify no ringing sound

# 5. Check for errors
sm_dump_handles  # Check for handle leaks
```

## CI/CD Pipeline

### GitHub Actions Workflow
- **Trigger**: Push, PR, or manual dispatch
- **Build**: Uses SourceKnight action to compile plugin
- **Package**: Creates release artifacts with proper directory structure
- **Release**: Automatic releases on tags or main branch pushes

### Release Process
1. **Version Bump**: Update version in plugin info
2. **Tag**: Create git tag with semantic version (e.g., v1.1.1)
3. **Automatic**: CI builds and creates GitHub release
4. **Assets**: Tar.gz package with compiled plugin and gamedata

## Plugin Architecture

### Core Functionality
This plugin implements a simple but effective solution using DHooks:

1. **Initialization**: Loads game offsets from gamedata file
2. **Hook Setup**: Creates DHook for `OnDamagedByExplosion` function
3. **Client Hooking**: Hooks each client when they join the server
4. **Interception**: Blocks the function call to prevent ringing sound

### Hook Flow
```
Game Event: Grenade Explosion
    ↓
CCSPlayer::OnDamagedByExplosion() called
    ↓
DHook intercepts the call
    ↓
OnDamagedByExplosion callback executed
    ↓
Return value set to 0, call superceded
    ↓
No ringing sound effect played
```

### Critical Implementation Details
- **Hook Type**: `HookType_Entity` - hooks individual player entities
- **Return Handling**: Uses `DHookSetReturn(hReturn, 0)` to block effect
- **Return Behavior**: `MRES_Supercede` prevents original function execution
- **Late Loading**: Handles players already connected when plugin loads

## Common Modifications

### Adding New Hooks
```sourcepawn
// 1. Add to gamedata file
"NewFunction"
{
    "windows"    "123"
    "linux"      "124"
    "mac"        "124"
}

// 2. Create hook in OnPluginStart
Handle g_hNewFunction;
int offset = GameConfGetOffset(hTemp, "NewFunction");
g_hNewFunction = DHookCreate(offset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, OnNewFunction);

// 3. Hook entities
DHookEntity(g_hNewFunction, false, client);

// 4. Implement callback
public MRESReturn OnNewFunction(int pThis, Handle hReturn, Handle hParams)
{
    // Implementation
    return MRES_Ignored;
}
```

### Adding Configuration
```sourcepawn
// ConVars for runtime configuration
ConVar g_cvEnabled;
ConVar g_cvFlags;

public void OnPluginStart()
{
    g_cvEnabled = CreateConVar("sm_nogradering_enable", "1", "Enable/disable plugin");
    g_cvFlags = CreateConVar("sm_nogradering_flags", "z", "Admin flags required");
    
    AutoExecConfig(true, "NoGrenadeRinging");
}
```

## Performance Considerations

### Optimization Guidelines
- **Minimize Hook Usage**: Only hook necessary functions
- **Client Validation**: Always validate client indices
- **Early Returns**: Exit functions early when possible
- **Cache Results**: Store expensive lookups in global variables
- **Avoid Loops**: Minimize iteration in frequently called functions

### Memory Management
```sourcepawn
// Proper cleanup in OnPluginEnd
public void OnPluginEnd()
{
    if(g_hDamagedByExplosion != INVALID_HANDLE)
    {
        delete g_hDamagedByExplosion;
        g_hDamagedByExplosion = INVALID_HANDLE;
    }
}
```

## Version Control & Releases

### Semantic Versioning
- **MAJOR**: Breaking changes to plugin API or behavior
- **MINOR**: New features, new hooks, configuration options
- **PATCH**: Bug fixes, offset updates, performance improvements

### Commit Guidelines
- Clear, descriptive commit messages
- Reference issue numbers when applicable
- Keep changes focused and atomic
- Test changes before committing

## Troubleshooting

### Common Issues
1. **Compilation Errors**: Check SourcePawn syntax and includes
2. **Load Failures**: Verify gamedata file and offsets
3. **Hook Failures**: Ensure game updates haven't changed offsets
4. **Memory Leaks**: Use proper handle cleanup patterns

### Debug Techniques
```sourcepawn
// Debug logging
LogMessage("Hook created successfully");
LogError("Failed to hook function: %d", offset);

// Client debugging
PrintToServer("Client %N triggered hook", client);
PrintToConsole(client, "Debug: Function called");
```

This plugin serves as an excellent example of DHooks usage for intercepting game functions and modifying behavior without game engine modifications.