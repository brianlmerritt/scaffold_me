# Svelte 5 Runes SPA - Personal Dashboard

I need a modern single-page application built with Svelte 5 Runes that serves as a personal productivity dashboard.

## What I Want

A clean, fast SPA where I can:
- Track daily tasks with drag-and-drop functionality
- Monitor my goals and progress with visual charts
- Take quick notes and save them locally
- View weather and calendar information
- Customize themes (light/dark mode)
- Work offline with local storage
- Have smooth animations and transitions

## Technical Preferences

- **Framework**: Svelte 5 with Runes (latest stable version)
- **Language**: TypeScript for type safety
- **Styling**: Tailwind CSS for rapid styling
- **State Management**: Svelte 5 runes ($state, $derived, $effect)
- **Build Tool**: Vite for fast development
- **Testing**: Vitest for unit testing
- **Code Quality**: ESLint + Prettier for consistency

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

### 1. Start scaffolding now with scaffold_me.md agent.  Do not wait for go - just start!

### 2. Research Latest Installation
- Search for the latest Svelte 5 and `npx sv create` installation instructions
- Find the current CLI options and add-on selections available
- Verify the current recommended TypeScript and tooling setup
- Double check node and npm version requirements - currently  required: { node: '^20.19 || ^22.12 || >=24' } but double check

### 3. Guide User Through Installation
- Display clear instructions on which options to select during `npx sv create`
- Recommend specific add-ons needed: TypeScript, Tailwind, ESLint, Prettier, Vitest
- Explain why each selection is recommended for this SPA project

### 4. Configure for SPA
After the initial scaffold, you must:
- Install and configure `@sveltejs/adapter-static` for SPA deployment
- Modify `svelte.config.js` with proper SPA settings (fallback: 'index.html')
- Update any necessary configuration files for SPA mode

### 5. Create Working Application
- Build a complete `+layout.svelte` with navigation and dark mode using runes
- Create a functional `+page.svelte` with real Svelte 5 runes examples ($state, $derived, $effect)
- Ensure the app demonstrates proper runes patterns and TypeScript integration
- Configure Tailwind for dark mode support
- Verify the application runs without errors after `npm run dev`

### 6. Generate Documentation
Create two essential documentation files:
- **README.md**: Complete project documentation with current commands, structure, deployment instructions, and troubleshooting
- **CLAUDE.md**: AI development context with latest Svelte 5 runes best practices, project architecture, and development guidelines

### 7. Verify Everything Works
- Test that `npm run dev` starts the development server
- Verify `npm run build` creates a deployable SPA
- Confirm all TypeScript types are working
- Check that the example functionality (todos, dark mode) works correctly

## Scaffold Options

The scaffold agent should ask the user these questions during setup:

### Component Library
- **Question**: "Do you want to use DaisyUI for pre-built Svelte components?"
- **Options**: Yes (install daisyui + configure), No (custom components only)
- **Default**: No
- **Impact**: Installs daisyui, configures tailwind.config.js with daisyui plugin

### Icon Library
- **Question**: "Which icon library would you prefer?"
- **Options**: Lucide Svelte, Heroicons, Tabler Icons, None
- **Default**: Lucide Svelte
- **Impact**: Installs chosen library, creates example icon components

### Animation Framework
- **Question**: "Include animation utilities?"
- **Options**: Svelte transitions only, Motion One, CSS animations
- **Default**: Svelte transitions only

**Remember**: Search for current information rather than using outdated examples. The goal is a working, modern Svelte 5 Runes SPA that demonstrates best practices and is ready for development.