import React from 'react';
import { NavLink } from 'react-router-dom';
import { 
  LayoutDashboard, 
  ClipboardCheck, 
  Users, 
  Layers, 
  ArrowUpRight,
  Shield,
  HelpCircle
} from 'lucide-react';

export default function Sidebar({ pendingCount = 1 }) {
  const links = [
    { to: '/admin/dashboard', label: 'Dashboard Overview', icon: LayoutDashboard },
    { to: '/admin/reviews', label: 'Manual Review Queue', icon: ClipboardCheck, badge: pendingCount },
    { to: '/admin/unreached', label: 'Unreached Students', icon: Users, badge: '300' },
    { to: '/admin/verification', label: 'Verification Layer', icon: Layers },
  ];

  return (
    <aside className="w-64 bg-slate-900 text-slate-300 flex flex-col min-h-screen shrink-0 border-r border-slate-800">
      {/* Branding Header */}
      <div className="p-6 border-b border-slate-800 flex items-center space-x-3">
        <div className="h-9 w-9 rounded-lg bg-emerald-600 text-white flex items-center justify-center font-bold text-lg">
          J
        </div>
        <div>
          <span className="text-white font-bold tracking-wide text-base">JAGO — MoTA</span>
          <p className="text-[11px] text-emerald-400 font-medium">Smart Verification Portal</p>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 p-4 space-y-1.5">
        <div className="px-3 py-2 text-[11px] font-semibold tracking-wider text-slate-500 uppercase">
          Administrative Modules
        </div>

        {links.map((link) => {
          const Icon = link.icon;
          return (
            <NavLink
              key={link.to}
              to={link.to}
              className={({ isActive }) =>
                `flex items-center justify-between px-3.5 py-2.5 rounded-lg text-xs font-medium transition ${
                  isActive
                    ? 'bg-emerald-600 text-white shadow-sm'
                    : 'text-slate-400 hover:text-white hover:bg-slate-800/80'
                }`
              }
            >
              <div className="flex items-center space-x-3">
                <Icon className="w-4 h-4 shrink-0" />
                <span>{link.label}</span>
              </div>
              {link.badge !== undefined && (
                <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-amber-500 text-slate-950">
                  {link.badge}
                </span>
              )}
            </NavLink>
          );
        })}
      </nav>

      {/* Cross link to mobile/student view & documentation */}
      <div className="p-4 border-t border-slate-800 space-y-2">
        <div className="bg-slate-800/60 rounded-lg p-3 text-xs border border-slate-700/60">
          <div className="flex items-center justify-between text-slate-300 font-semibold mb-1">
            <span>MoTA Verification Engine</span>
            <Shield className="w-3.5 h-3.5 text-emerald-400" />
          </div>
          <p className="text-[11px] text-slate-400 leading-relaxed">
            "Reuse what is verified. Revalidate what changes. Route what needs review."
          </p>
        </div>
      </div>
    </aside>
  );
}
