import React from 'react';
import { ShieldCheck, UserCheck, Bell, ExternalLink, LogOut } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

export default function Header({ user, onLogout }) {
  const navigate = useNavigate();

  return (
    <header className="bg-white border-b border-slate-200 sticky top-0 z-30 px-6 py-3.5 flex items-center justify-between shadow-sm">
      <div className="flex items-center space-x-3">
        <div className="h-10 w-10 rounded-lg bg-emerald-700 text-white flex items-center justify-center font-bold text-xl shadow-inner">
          🏛️
        </div>
        <div>
          <div className="flex items-center space-x-2">
            <h1 className="text-lg font-bold text-slate-800 leading-tight">JAGO Admin Portal</h1>
            <span className="bg-emerald-100 text-emerald-800 text-xs px-2 py-0.5 rounded-full font-semibold border border-emerald-300">
              Demo / Mock
            </span>
          </div>
          <p className="text-xs text-slate-500 font-medium">
            Ministry of Tribal Affairs, Govt of India • National Scholarship Verification
          </p>
        </div>
      </div>

      <div className="flex items-center space-x-4">
        {/* Live Simulation Indicator */}
        <div className="hidden md:flex items-center space-x-2 bg-emerald-50 border border-emerald-200 text-emerald-700 px-3 py-1 rounded-md text-xs font-medium">
          <span className="h-2 w-2 rounded-full bg-emerald-500 animate-ping"></span>
          <span>Unified Integration Layer Active</span>
        </div>

        <div className="h-6 w-px bg-slate-200"></div>

        {/* Officer Profile */}
        <div className="flex items-center space-x-3">
          <div className="h-9 w-9 rounded-full bg-slate-100 border border-slate-300 flex items-center justify-center text-slate-700 font-semibold text-sm">
            AS
          </div>
          <div className="hidden lg:block text-left">
            <p className="text-xs font-semibold text-slate-800 leading-tight">
              Dr. Ananya Sharma
            </p>
            <p className="text-[11px] text-slate-500">MoTA Verification Officer</p>
          </div>
        </div>

        {/* Logout */}
        <button
          onClick={onLogout}
          title="Sign Out"
          className="p-2 rounded-lg text-slate-500 hover:text-red-600 hover:bg-red-50 transition"
        >
          <LogOut className="w-4 h-4" />
        </button>
      </div>
    </header>
  );
}
