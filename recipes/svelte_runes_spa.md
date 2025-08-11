# Svelte 5 Runes SPA - Personal Dashboard

We need a modern single-page application scaffolded with Svelte 5 Runes.

## What I Want

A clean, fast SPA where I can:
- Have Svelte 5 runes and packages already installed and configured
- Documentation saved in the README.md on how to run and develop this SPA
- Simple "This project has been scaffolded by scaffold_me" on the Svelte 5 Home page

## Technical Preferences

- **Framework**: Svelte 5 with Runes (latest stable version)
- **Language**: TypeScript for type safety
- **Styling**: Tailwind CSS for rapid styling
- **State Management**: Svelte 5 runes ($state, $derived, $effect)
- **Build Tool**: Vite for fast development
- **Testing**: Vitest for unit testing
- **Code Quality**: ESLint + Prettier for consistency
- **Playwright**: Installed in case the user needs it

## Must Have

- **Svelte 5 Runes**: Use $state, $derived, $effect for reactivity
- **Responsive Design**: Works on desktop, tablet, and mobile
- **Local Storage**: Persist data without a backend
- **Component Architecture**: Reusable, well-organized components
- **Type Safety**: Full TypeScript integration
- **Development Environment**: Hot reload, error overlay, debugging tools
- **Modern CSS**: Grid, flexbox, custom properties
- **Performance**: Fast loading and smooth interactions

## Nice to Have

- **Animations**: Svelte transitions and spring animations
- **PWA Features**: Service worker for offline functionality
- **Testing Setup**: Unit tests for components and utils
- **Documentation**: Component stories or examples
- **Deployment Ready**: Build configuration for static hosting
- **Code Formatting**: Automatic formatting on save
- **Accessibility**: ARIA labels, keyboard navigation, screen reader support

## Design Style

- **Modern & Minimal**: Clean lines, plenty of whitespace
- **Color Palette**: Subtle gradients, good contrast ratios
- **Typography**: Readable fonts, proper hierarchy
- **Interactions**: Subtle hover effects, smooth transitions
- **Mobile-First**: Responsive design starting from mobile

---

## Scaffold Agent Instructions

**IMPORTANT**: You must perform these steps to scaffold this project correctly:

### 1. Tell the user what is going on:
- We are installing Svelte 5 with Runes using npm and typescript in the current directory - this works better if the directory is empty
- Once Svelte is installed we will be adding prettier, eslint, vitest, tailwindcss and playwright
- For this scaffold to work, we recommend the user is already on npm 24 or above

### 2. Svelte 5 install
- Check the current directory, and if not empty ask the user if they are sure they want to proceed.  Y=Yes, n (default) is no.  If they say `n`, run `ls -al` of the current directory and stop, otherwise continue.
- Check node version.  If less than 24 ask the user if they are sure they want to proceed.  Y=Yes, n (default) is no.  If they say `n`, run `node --version` and stop, otherwise continue.
- Run this command to install Svelte 5 runes without extra input `npx sv create . --template=minimal --no-add-ons --install npm --types ts` and check the output.
- If successful, run `npm install prettier eslint vitest tailwindcss playwright`

### 3. Configure for SPA
After the initial scaffold, you must:
- Install and configure `@sveltejs/adapter-static` for SPA deployment
- Modify `svelte.config.js` with proper SPA settings (fallback: 'index.html')
- Update any necessary configuration files for SPA mode

### 4. Create Working Application
- Build a simple `+layout.svelte` SPA page using runes 
- Create a functional `+page.svelte` with real Svelte 5 runes examples ($state, $derived, $effect) welcoming the user with the message "This project template was created using scaffold_me"
- Ensure the app demonstrates proper runes patterns and TypeScript integration
- Verify the application runs without errors after `npm run dev`

### 5. Additional Install Options
#### Component Library
- **Question**: "Do you want to use DaisyUI for pre-built Svelte components?"
- **Options**: Yes (install daisyui + configure), No (custom components only)
- **Default**: No
- **Impact**: Installs daisyui, configures tailwind.config.js with daisyui plugin and updates documentation README.md and CLAUDE.md

#### Icon Library
- **Question**: "Which icon library would you prefer?"
- **Options**: Lucide Svelte, Heroicons, Tabler Icons, None
- **Default**: Lucide Svelte
- **Impact**: Installs chosen library, creates example icon components

#### Animation Framework
- **Question**: "Include animation utilities?"
- **Options**: Svelte transitions only, Motion One, CSS animations
- **Default**: Svelte transitions only

### 6. Generate Documentation
Create two essential documentation files:
- **README.md**: Complete project scaffold documentation with current npm etc commands, structure, deployment instructions, and troubleshooting
- **CLAUDE.md**: AI development context with latest Svelte 5 runes best practices, project architecture, and development guidelines

### 7. Verify Everything Works
- Test that `npm run dev` starts the development server
- Verify `npm run build` creates a deployable SPA
- Confirm all TypeScript types are working
- Check that the example functionality (todos, dark mode) works correctly

**Remember**: Search for current information rather than using outdated examples. The goal is a working, modern Svelte 5 Runes SPA that demonstrates best practices and is ready for development.