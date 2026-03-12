# Claude Rules and Guidelines

## Repository Update Protocol

### Always Update Repository Before Tasks
**MANDATORY**: Before executing any task that involves code changes, analysis, or repository operations, ALWAYS perform the following update sequence:

#### For ssh-and-network-tuning Repository
**PRIMARY REPOSITORY**: `/projects/69b235ed78cc8ded7792d113/ssh-and-network-tuning`

1. **Navigate to Repository**
   ```bash
   cd /projects/69b235ed78cc8ded7792d113/ssh-and-network-tuning
   ```

2. **Check Repository Status**
   ```bash
   git status
   ```

3. **Fetch Latest Changes**
   ```bash
   git fetch origin
   ```

4. **Pull Latest Changes** (if on a branch that tracks remote)
   ```bash
   git pull origin main
   ```
   or
   ```bash
   git pull origin $(git branch --show-current)
   ```

5. **Verify Working Directory is Clean**
   - If there are uncommitted changes, ask user for guidance
   - If conflicts exist, resolve them before proceeding

6. **Return to Project Root** (if needed)
   ```bash
   cd /projects/69b235ed78cc8ded7792d113
   ```

### Exception Cases
- **Quick read-only operations**: Simple file viewing or status checks may skip update
- **User explicitly requests no update**: Honor user preference but warn about potential staleness
- **Working on feature branch**: Update feature branch appropriately

### Implementation Notes
- This rule ensures we're always working with the latest codebase
- Prevents conflicts and ensures consistency
- Critical for collaborative environments
- Should be the first step in any substantial task workflow
- **SPECIFIC TO**: ssh-and-network-tuning repository in this project

### Automated Update Script
For convenience, use this command sequence at the start of any task:
```bash
# Quick update command for ssh-and-network-tuning repo
cd /projects/69b235ed78cc8ded7792d113/ssh-and-network-tuning && git fetch origin && git pull && cd /projects/69b235ed78cc8ded7792d113
```

### Enforcement Protocol
1. **Before any code modification task**: Execute repository update
2. **Before any analysis task**: Execute repository update  
3. **Before any build/test task**: Execute repository update
4. **Before any configuration change**: Execute repository update

---
*This rule is automatically enforced for all repository operations.*